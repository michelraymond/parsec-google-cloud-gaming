# Parsec + Google Cloud Gaming PC

### What is this?

This repo sets you up to play games like [Doom Eternal](https://store.steampowered.com/app/782330/DOOM_Eternal/) on your own laptop! You can play with all graphics set to max since you'll be streaming the screen from a beefy gaming PC in Google Cloud.

We just need to set up two things:

- [A Parsec account](https://parsec.app/). This lets us stream the screen from the server at super low latency. It's like [Google Stadia](https://store.google.com/product/stadia?gclid=CjwKCAjwguzzBRBiEiwAgU0FT7GirMrN5XiJOHrRMcFNXx6Y1a3BGxoZ2mX1wEKSO5e-3urfE4NeoxoCwd8QAvD_BwE) but better, in my humble opinion.
- A Google Cloud virtual machine with a [Telsa P100 GPU](https://www.microway.com/knowledge-center-articles/comparison-of-nvidia-geforce-gpus-and-nvidia-tesla-gpus/) running Windows Server 2019
  - If you haven't signed up for Google Cloud before, you get **$300 in credits for free!**
  - The virtual machine **costs about $1.30/hour** to run. Don't worry about getting overcharged — we'll set up your machine to shut down automatically when you're done playing

---

### Guide

This should take about 30 minutes to set up. Could take longer depending on how fast Google responds to you via email after step 4.

1. [Sign up for Google Cloud.](https://cloud.google.com/gcp/) Choose the Google account you'll want to get your bill under.
1. Once you're at the main Google Cloud console page ([console.cloud.google.com](https://console.cloud.google.com/)), let's create a new Project
   1. Click `My First Project` at the top of the page
        ![a](https://dl.dropboxusercontent.com/s/vduxhpl4dgwnhw5/Screenshot%202020-03-25%2020.28.47.png?dl=0)
   1. Click `NEW PROJECT` at the top-right of the modal
   1. Call your new project `Parsec`
   1. Wait until your new project has finished creating
   1. **Important:** Use the same button to change to your new `Parsec` project. If you do this correctly, you should see this:
        ![](https://dl.dropboxusercontent.com/s/1i3u6zdj2y3vuqj/Screenshot%202020-03-28%2018.26.03.png?dl=0)
1. Using the search bar up top, search `vm instances` and click the result labeled "VM Instances"
       ![b](https://dl.dropboxusercontent.com/s/0uzkuqcssfim1oa/Screenshot%202020-03-25%2020.36.46.png?dl=0)
   1. You'll be brought to a screen saying
   
        > Compute Engine is getting ready.
        
      Wait for this message to go away — this should take a few minutes.
   1. Click `Create` __but don't do anything else__. Move on to the next step.
1. Request an increase to your GPU quota. We need to ask Google Cloud to let us create a machine with a GPU attached.
   1. On the "create an instance" page, click on "GPUs", google should prompt you to upgrade your free account, click on upgrade to unlock it (beware that this will enable your account to spend more than the free 300€).
   2. Now on the same page, select the "nvidia tesla p100" gpu, google should prompt you with a "You might not have enough quota for this VM", click on "request quota adjustment" to increase your quota.
   1. Google now has to approve your quota increase. They'll send you an email when they confirm. This may take a while, but in practice it takes less than an hour. Move on to the next step while you wait.

1. [Download and install Parsec](https://parsec.app/). Open Parsec and make an account. You'll eventually need to sign in on the cloud machine as well, so **remember your username+password**!
    1. Go the the settings of Parsec and disable Vsync, and enable H265.
1. Download the default Service Account key. This will give Terraform permission to create your machine later in step 9.
    1. [Go back to the Google Cloud console](https://console.cloud.google.com/)
    1. Search `credentials` at the top and click "APIs & Services"
        ![g](https://dl.dropboxusercontent.com/s/0ussa3kfm19aa42/Screenshot%202020-03-25%2020.48.26.png?dl=0)
    1. In the left-hand drawer, click "Credentials"
    1. Under the "Service Accounts" section, click the one named "Compute Engine default service account"
        ![h](https://dl.dropboxusercontent.com/s/uv33vzp4a6uz0h4/Screenshot%202020-03-25%2020.50.02.png?dl=0)
    1. Click "Create Key" at the bottom, choose JSON
    1. Save the key as `account.json`.
1. Wait until Google Cloud approves your GPU quota increase from step 4.
1. Create the virtual machine. You'll need to open the Terminal for this step.

    **⚠️⚠️⚠️ WARNING! ⚠️⚠️⚠️** This step will start your cloud machine and **you will start getting charged!** Don't stop following the guide here, or make sure to stop the machine before leaving!!!
   1. In the Google Cloud console, copy your project ID from the dropdown at the top.
        ![](https://dl.dropboxusercontent.com/s/1i3u6zdj2y3vuqj/Screenshot%202020-03-28%2018.26.03.png?dl=0)
        ![](https://dl.dropboxusercontent.com/s/m0u54c7wslcs9ji/Screenshot%202020-03-28%2018.21.26.png?dl=0)
   2. Click on the "activate cloud shell" on the top right of any google cloud page to open a gcp terminal.
   3. Use [Terraform](https://www.terraform.io/) to automatically set up your machine. Open terminal and run the following
    
    ```bash
    git clone https://github.com/michelraymond/parsec-google-cloud-gaming.git
    cd parsec-google-cloud-gaming/terraform
    nano main.tf  # change the placeholder at the top with your project ID
    nano account.json  # copy the content of your account.json
    terraform init
    terraform apply
    ```
    
1. Set a Windows password
    1. [Go back to the Google Cloud console](https://console.cloud.google.com/)
    1. Using the search bar up top, search `vm instances` and click the result labeled "VM Instances"
        ![i](https://dl.dropboxusercontent.com/s/0uzkuqcssfim1oa/Screenshot%202020-03-25%2020.36.46.png?dl=0)
    1. Click on your newly created instance called `parsec-1`
    1. Near the top of the page, click "Set Windows password"
        ![j](https://dl.dropboxusercontent.com/s/aopu2eouf3notxh/Screenshot%202020-03-25%2021.00.15.png?dl=0)
    1. Follow the instructions and **save the generated password**
1. Use RDP to connect to Windows VM
    1. Click "RDP" near the top of the instance info page
    1. Click on "Download the RDP file if you will be using a third-party client."
    2. Install the windows remote desktop app from here: https://www.microsoft.com/store/productId/9WZDNCRFJ3PS
    3. double click on the downloaded file and connect using the windows password above
1. Once you're on the remote desktop via RDP, let's set up Parsec. **This step takes a while.**
    1. Follow steps 3 and 4 at https://github.com/kaktus42/Parsec-Cloud-Preparation-Tool (don't install the GPU driver with the program, you will install it below)
    1. To Setup Auto Shutdown with the task scheduler just follow this: https://www.makeuseof.com/windows-10-11-shutdown-idle/ just change task trigger as "on idle" (the built-in auto shutdown shortcut on desktop doesn't work)
    1. Open Google Chrome and download the Google Cloud NVIDIA driver from here: https://cloud.google.com/compute/docs/gpus/grid-drivers-table#windows_drivers
    1. Run the downloaded `.exe` to install the driver, maybe use older version if latest won't work (I used the 538.33 since the 551.61 wasn't working)

1. Last bit of setup. Home stretch!
    1. From the windows remote desktop app, open Parsec and sign in
    1. Go to Settings. Scroll to the bottom and check H265 (same as client)
    2. If needed go to the windows language settings to change the keyboard layout (US qwerty by default)
    3. You'll need to type your login password with Parsec, if the google generated one is too complicated, you can change it by going in the "sign in options" page of the windows settings. Note that changing the windows password will make you unable to reconnect with RDP. If you need to reconnect using RDP you'll have to reset your windows password using the "Set windows password" button as above.
    4. Close the windows remote desktop app.
1. On your host, open Parsec and connect to your cloud machine.
    1. If the display isn't right, right click the desktop and open "Display Settings"
    1. Set the scaling factor to 150%, and adjust the resolution if needed.
    2. **Done!!!**

At this point, you can install Steam and whatever games you want. Voila!

**Don't forget to turn off your machine when you're not using it, or you'll be charged!** Google Cloud charges by the second. You can check how much your instance cost you per day by going to the reports page of the billing section https://console.cloud.google.com/billing/ . If you still have free credits, uncheck the "Promotions and others" on the right to see the graphic.

----

### Troubleshooting
  - Maybe set GPU into WDDM mode: https://docs.nvidia.com/gameworks/content/developertools/desktop/nsight/tesla_compute_cluster.htm
