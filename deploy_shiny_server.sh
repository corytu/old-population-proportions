yum install -y R libpng-static libpng-devel geos geos-devel wget
su - -c "R -e \"install.packages(c('shiny', 'magrittr', 'maptools', 'leaflet', 'rgeos'), repo = 'https://cloud.r-project.org/')\""
wget https://download3.rstudio.org/centos6.3/x86_64/shiny-server-1.5.7.907-rh6-x86_64.rpm
yum install -y --nogpgcheck shiny-server-1.5.7.907-rh6-x86_64.rpm
# gcloud compute firewall-rules create shiny-conn --allow=tcp:3838 --target-tags shiny-server  --quiet
gcloud compute instances add-tags instance-1 --tags shiny-server --quiet
# git clone from https://github.com/corytu/OldPopulationProportions.git earlier
mv ./OldPopulationProportions/ /srv/shiny-server/
