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
  course_1.jpg course_2.jpg course_3.jpg course_4.jpg course_5.jpg
  course_6.jpg course_7.jpg course_8.jpg course_9.jpg course_10.jpg
  favicon.ico
  golf_course_1.mp4
]
