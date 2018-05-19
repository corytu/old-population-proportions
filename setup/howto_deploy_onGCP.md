1. 在GCP主控臺上選擇想要的機器類型（這次用的是n1-standard-1（1個vCPU，3.75 GB記憶體））、開機磁碟（我用CentOS 7），以及區域位置（我想臺灣應該算東亞），API存取權設定成「__允許所有Cloud API的完整存取權__」（這樣之後比較方便），以及因應Shiny Server的需要，將防火牆設成「__允許HTTP流量__」。
2. SSH連入剛建立好的instance，開始安裝需要的軟體與套件：
    
    ```shell
    # 安裝R
    sudo yum install R
    # 安裝需要的Linux套件（這是為了leaflet和rgeos兩個R套件而做的，否則它們待會會安裝失敗）
    sudo yum install libpng-static libpng-devel
    sudo yum install geos geos-devel
    # 安裝本次會用到的R套件
    sudo su - -c "R -e \"install.packages(c('shiny', 'magrittr', 'maptools', 'leaflet', 'rgeos'), repo = 'https://cloud.r-project.org/')\""
    # 安裝Shiny Server
    sudo yum install wget
    wget https://download3.rstudio.org/centos6.3/x86_64/shiny-server-1.5.7.907-rh6-x86_64.rpm
    sudo yum install --nogpgcheck shiny-server-1.5.7.907-rh6-x86_64.rpm
    ```

3. 觀察Shiny Server的預設值：`more /etc/shiny-server/shiny-server.conf`
4. 設定防火牆。這裡GCP似乎有自己的玩法，所以不是用iptables來管理。

    ```shell
    # 設定防火牆規則（只有第一次在GCP建立規則時需要這行）
    sudo gcloud compute firewall-rules create shiny-conn --allow=tcp:3838 --target-tags shiny-server
    # 把設定好的規則套用在這個instance上（這裡我的instance就叫instance-1）
    sudo gcloud compute instances add-tags instance-1 --tags shiny-server
    ```

5. 用外部IP檢查是否可以順利透過3838 port連線到Shiny Server（`http://<the external IP>:3838`）。如果看到Shiny Server的歡迎畫面，代表Shiny Server的設置及網路防火牆沒有問題。

    ![alt text][welcome]

[welcome]: shiny_server_welcome.png "Welcome to Shiny Server!"

6. 將需要的Shiny app相關檔案放到instance裡面，這裡用與GCP上的bucket協同的方式，當然，也可以用`git clone`直接把專案從GitHub抓過去。

    ```shell
    # 把事先在Google Cloud Storage bucket上準備好的檔案載過來
    sudo gsutil cp -r gs://old-population-proportions/ /srv/shiny-server/
    ```

7. 在剛剛歡迎畫面的網址後面再加上Shiny資料夾的名稱，即`http://<the external IP>:3838/<name of the app folder>/`，完成！
8. 進階的部分還有許多細節可以調整，例如指定用哪一個帳號去執行部署出去的Shiny apps，或者啟動及沒有新連線之後逾時（timeout）的秒數，都可以在前述的`/etc/shiny-server/shiny-server.conf`裡設定。Shiny Server Administrator's Guide有很詳盡的說明。

參考資料：

- Shiny official documentation
    - [Installing Shiny Server Open Source](https://www.rstudio.com/products/shiny/download-server/)
    - [Shiny Server Professional v1.5.7 Administrator's Guide](http://docs.rstudio.com/shiny-server/)
- GCP official documentation
    - [Using Firewall Rules](https://cloud.google.com/vpc/docs/using-firewalls)
    - [Transferring Files to Instances](https://cloud.google.com/compute/docs/instances/transfer-files)
- Open tutorial
    - [RStudio-Shiny-Server-on-GCP: The ultimate guide to deploy Rstudio Open Source and Shiny Server Open Source at Google Cloud Platform](https://github.com/paeselhz/RStudio-Shiny-Server-on-GCP/)
- Stack Overflow
    - [RStudio Server not running on Google Cloud Compute Engine](https://stackoverflow.com/questions/44914643/rstudio-server-not-running-on-google-cloud-compute-engine)
    - [png.h file not found](https://stackoverflow.com/questions/36674667/png-h-file-not-found-linux/)
    - [Unable to install rgdal and rgeos R libraries on Red Hat Linux](https://stackoverflow.com/questions/21683138/unable-to-install-rgdal-and-rgeos-r-libraries-on-red-hat-linux/)
