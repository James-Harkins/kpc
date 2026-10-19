require 'rails_helper'

RSpec.describe Trip, 'bed availability' do
  let(:trip)  { create(:trip) }
  let(:house) { create(:house, trip: trip) }
  let(:room)  { create(:bedroom, house: house) }
  let!(:nights) { Array.new(3) { create(:night, trip: trip) } }

  def attend(golfer, *attended_nights)
    attended_nights.each { |night| create(:golfer_night, golfer: golfer, night: night) }
    create(:golfer_trip, golfer: golfer, trip: trip)
  end

  describe '#total_bed_spots' do
    it 'sums bed capacities across every house on the trip' do
      create(:bed, bedroom: room, capacity: 2)
      create(:bed, bedroom: create(:bedroom, house: create(:house, trip: trip)), capacity: 1)
      create(:bed, bedroom: create(:bedroom, house: create(:house)), capacity: 2)
      expect(trip.total_bed_spots).to eq(3)
    end

    it 'is zero when no beds have been entered' do
      expect(trip.total_bed_spots).to eq(0)
    end
  end

  describe '#open_bed_spots_by_night / #open_bed_spots' do
    before { 2.times { create(:bed, bedroom: room, capacity: 1) } }

    it 'is every spot on an empty trip' do
      expect(trip.open_bed_spots_by_night.map(&:last)).to eq([2, 2, 2])
      expect(trip.open_bed_spots).to eq(2)
    end

    it 'counts a spot against only the nights the golfer attends' do
      attend(create(:golfer), nights[0], nights[1])
      expect(trip.open_bed_spots_by_night.map(&:last)).to eq([1, 1, 2])
    end

    it 'treats an early leaver and a late arriver as one bed position' do
      attend(create(:golfer), *nights)
      attend(create(:golfer), nights[0], nights[1])
      expect(trip.open_bed_spots_by_night.map(&:last)).to eq([0, 0, 1])

      attend(create(:golfer), nights[2])
      expect(trip.open_bed_spots_by_night.map(&:last)).to eq([0, 0, 0])
    end

    it 'has no full-week bed once any night is full, but still has room on other nights' do
      attend(create(:golfer), *nights)
      attend(create(:golfer), nights[0], nights[1])
      expect(trip.open_bed_spots).to eq(0)
      expect(trip.open_bed_spots_any_night).to eq(1)
      expect(trip.full_night_ids).to match_array([nights[0].id, nights[1].id])

      attend(create(:golfer), nights[2])
      expect(trip.open_bed_spots_any_night).to eq(0)
      expect(trip.full_night_ids).to match_array(nights.map(&:id))
    end

    it 'does not report a middle-of-the-week gap as an open bed' do
      attend(create(:golfer), nights[0], nights[2])
      attend(create(:golfer), *nights)
      expect(trip.open_bed_spots_by_night.map(&:last)).to eq([0, 1, 0])
      expect(trip.open_bed_spots).to eq(0)
    end

    it 'reports every spot as full-week open on an empty trip' do
      expect(trip.open_bed_spots).to eq(2)
      expect(trip.full_night_ids).to eq([])
    end

    it 'never goes below zero when overbooked' do
      3.times { attend(create(:golfer), *nights) }
      expect(trip.open_bed_spots_by_night.map(&:last)).to eq([0, 0, 0])
    end

    it 'reopens a bed when a golfer drops nights' do
      2.times { attend(create(:golfer), *nights) }
      expect(trip.open_bed_spots).to eq(0)
      GolferNight.where(night: nights[1]).first.destroy
      expect(trip.open_bed_spots_any_night).to eq(1)
      expect(trip.open_bed_spots).to eq(0)
      GolferNight.where(golfer_id: GolferTrip.first.golfer_id).destroy_all
      expect(trip.open_bed_spots).to eq(1)
    end

    context 'with a golfer reserved all week' do
      it 'holds the spot on nights they are away' do
        attend(create(:golfer), nights[1], nights[2]).update!(reserved_all_week: true)
        expect(trip.open_bed_spots_by_night.map(&:last)).to eq([1, 1, 1])
      end

      it 'does not double count the nights a reserved golfer attends' do
        attend(create(:golfer), *nights).update!(reserved_all_week: true)
        expect(trip.open_bed_spots_by_night.map(&:last)).to eq([1, 1, 1])
      end

      it 'still opens a spot for a golfer who is not reserved and is away' do
        attend(create(:golfer), nights[1], nights[2]).update!(reserved_all_week: true)
        attend(create(:golfer), nights[0])
        expect(trip.open_bed_spots_by_night.map(&:last)).to eq([0, 1, 1])
      end

      it 'reaches true zero when reserved golfers fill every spot' do
        2.times { attend(create(:golfer), nights[2]).update!(reserved_all_week: true) }
        expect(trip.open_bed_spots).to eq(0)
      end
    end

    it 'is zero for a trip with no nights' do
      expect(create(:trip).open_bed_spots).to eq(0)
    end
  end

  describe '#bed_alert_recipients' do
    it 'excludes registered golfers and opted-out golfers' do
      registered = create(:golfer)
      opted_out  = create(:golfer)
      waiting    = create(:golfer)
      create(:golfer_trip, golfer: registered, trip: trip)
      create(:bed_alert_opt_out, golfer: opted_out, trip: trip)
      expect(trip.bed_alert_recipients).to contain_exactly(waiting)
    end

    it 'only honors opt-outs for this trip' do
      golfer = create(:golfer)
      create(:bed_alert_opt_out, golfer: golfer, trip: create(:trip))
      expect(trip.bed_alert_recipients).to include(golfer)
    end
  end

  describe '#send_bed_alerts' do
    let(:signer) { create(:golfer) }
    let!(:waiting) { create(:golfer) }
    let!(:admin) { create(:golfer, :admin) }

    context 'with no beds entered' do
      it 'blocks no nights' do
        expect(trip.full_night_ids).to eq([])
      end

      it 'sends nothing' do
        expect { trip.send_bed_alerts(signer, true) }.not_to have_enqueued_job(BulkMailJob)
      end
    end

    context 'with beds' do
      before { create(:bed, bedroom: room, capacity: 1) }

      it 'emails the unregistered golfers the bed count' do
        expect { trip.send_bed_alerts(signer, true) }
          .to have_enqueued_job(BulkMailJob)
          .with('bed_availability', a_collection_including(waiting.id, admin.id), trip)
      end

      it 'does not email golfers for an admin signup' do
        expect { trip.send_bed_alerts(admin, true) }.not_to have_enqueued_job(BulkMailJob)
      end

      it 'alerts the admins once when a signup takes the trip to zero' do
        attend(signer, *nights)
        expect { trip.send_bed_alerts(signer, true) }
          .to have_enqueued_job(BulkMailJob).with('bed_capacity_reached', [admin.id], trip)
          .and have_enqueued_job(BulkMailJob).with('bed_availability', anything, trip)
      end

      it 'does not re-alert the admins when the trip was already at zero' do
        attend(signer, *nights)
        expect { trip.send_bed_alerts(signer, false) }
          .not_to have_enqueued_job(BulkMailJob).with('bed_capacity_reached', anything, trip)
      end

      it 'still alerts the admins when an admin signup takes the trip to zero' do
        attend(admin, *nights)
        expect { trip.send_bed_alerts(admin, true) }
          .to have_enqueued_job(BulkMailJob).with('bed_capacity_reached', [admin.id], trip)
      end

      it 'sends at most one golfer blast per cooldown' do
        trip.send_bed_alerts(signer, true)
        expect { trip.send_bed_alerts(create(:golfer), true) }.not_to have_enqueued_job(BulkMailJob)
      end

      it 'sends again once the cooldown has passed' do
        trip.send_bed_alerts(signer, true)
        trip.update_column(:last_bed_alert_at, (Trip::BED_ALERT_COOLDOWN + 1.minute).ago)
        expect { trip.send_bed_alerts(create(:golfer), true) }
          .to have_enqueued_job(BulkMailJob).with('bed_availability', anything, trip)
      end

      it 'ignores the cooldown when a signup takes the trip to zero' do
        trip.send_bed_alerts(signer, true)
        attend(signer, *nights)
        expect { trip.send_bed_alerts(signer, true) }
          .to have_enqueued_job(BulkMailJob).with('bed_availability', anything, trip)
      end

      it 'does not start the cooldown for an admin signup' do
        trip.send_bed_alerts(admin, true)
        expect(trip.reload.last_bed_alert_at).to be_nil
      end

      it 'does not alert the admins while beds remain' do
        expect { trip.send_bed_alerts(signer, true) }
          .not_to have_enqueued_job(BulkMailJob).with('bed_capacity_reached', anything, trip)
      end
    end
  end
end
