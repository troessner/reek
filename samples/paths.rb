SAMPLES_PATH = Pathname.new(__dir__).relative_path_from(Pathname.pwd)
CONFIG_PATH = SAMPLES_PATH.join('configuration')
CLEAN_FILE = SAMPLES_PATH.join('clean.rb')
SMELLY_FILE = SAMPLES_PATH.join('smelly.rb')
