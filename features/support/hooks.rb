After('@remove-disable-smell-config-from-current-dir') do
  Pathname.pwd.join('reek-test-run-disable_smells.reek').delete
end

After('@remove-disable-smell-config-from-parent-dir') do
  Pathname.pwd.parent.join('reek-test-run-disable_smells.reek').delete
end

After('@remove-disable-smell-config-from-home-dir') do
  Pathname.new(Dir.home).join('reek-test-run-disable_smells.reek').delete
end

After('@remove-enable-smell-config-from-current-dir') do
  Pathname.pwd.join('reek-test-run-enable_smells.reek').delete
end
