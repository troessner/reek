namespace :samples do

  SAMPLES = Dir['spec/samples/*.rb']

  SAMPLES.each do |sample|
    fn = File.basename(sample)
    desc "run reek on sample #{fn}"
    task fn do
      sh "ruby -Ilib bin/reek #{sample}"
    end
    task :all => fn
  end
  
  desc 'run all samples'
  task :all
  
  desc 'update all golden sample reports to current reek status'
  task 'update' do
    SAMPLES.each do |sample|
      sh "ruby -Ilib bin/reek #{sample} > #{sample.ext('.reek')}" do |ok,status|
        0
      end
    end
  end
end
