SAMPLES_DIR = Pathname.new(__dir__).relative_path_from(Pathname.pwd)
CONFIGURATION_DIR = SAMPLES_DIR.join('configuration')
CLEAN_FILE = SAMPLES_DIR.join('clean_source').join('clean.rb')
SMELLY_FILE = SAMPLES_DIR.join('smelly_source').join('smelly.rb')

