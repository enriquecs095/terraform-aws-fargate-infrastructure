#! /bin/bash
sudo yum update -y
sudo yum install curl -y
echo "installing nodejs 14 and npm"
sudo yum install -y gcc-c++ make
curl -sL https://rpm.nodesource.com/setup_14.x | sudo -E bash -
sudo yum install -y nodejs
echo "install git and download the repository"
sudo yum install -y git
git -C /home/ec2-user clone https://github.com/enriquecs095/timeoff-management-application.git
echo "uninstall dependencies no longer needed"
sudo yum remove git -y
echo "install the dependencies"
cd /home/ec2-user
sudo chown -R $USER timeoff-management-application
sudo su
cd timeoff-management-application
npm install -g npm
npm i sqlite3 -D && rm -rf node_modules && npm i -y && npm rebuild
npm start
