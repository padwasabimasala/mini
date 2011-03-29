# Psuedo roles
# https://github.com/capistrano/capistrano/wiki/2.x-Multiple-Stages-Without-Multistage-Extension

task :admin do
  role :admin, 'admin.miningbased.com'
end

task :drone do
  role :drone, *%w[drone03.miningbased.com drone04.miningbased.com drone05.miningbased.com drone06.miningbased.com drone07.miningbased.com drone08.miningbased.com drone09.miningbased.com drone10.miningbased.com drone11.miningbased.com drone12.miningbased.com]
end

task :monitor do 
  role :monitor, 'monitor.miningbased.com'
end

task :queue do
  role :queue, *%w[queue01.miningbased.com queue02.miningbased.com]
end

task :production do
  drone
  admin
  monitor
end

task :hotfix do 
  role :hotfix, 'drone03.miningbased.com'
end

task :stage1 do 
  role :stage, 'drone03.miningbased.com'
end

task :stage2 do
  role :stage2, *%w[drone04.miningbased.com drone05.miningbased.com]
end

task :stage3 do
  role :stage3, *%w[drone06.miningbased.com drone07.miningbased.com drone08.miningbased.com drone09.miningbased.com]
end

task :stage4 do
  role :stage4, *%w[drone10.miningbased.com drone11.miningbased.com drone12.miningbased.com admin.miningbased.com monitor.miningbased.com]
end

task :micro_prod do
  role :micro, 'micro07.miningbased.com'
end

task :micro_stage do 
  role :micro, 'micro06.miningbased.com'
end
