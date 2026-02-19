# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path.
# Rails.application.config.assets.paths << Emoji.images_path
# Add Yarn node_modules folder to the asset load path.
Rails.application.config.assets.paths << Rails.root.join('node_modules')

# Precompile additional assets.
# Explicitly list images and video because link_tree/link_directory in manifest.js
# are Sprockets 4 features and behave as stubs in Sprockets 3.7.x.
Rails.application.config.assets.precompile += %w[
  course_1.jpeg course_2.jpeg course_3.jpeg course_4.jpeg course_5.jpeg
  course_6.jpeg course_7.jpeg course_8.jpeg course_9.jpeg course_10.jpeg
  favicon.ico
  golf_course_1.mp4
]
