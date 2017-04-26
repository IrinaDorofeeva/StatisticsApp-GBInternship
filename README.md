# StatisticsApp-GBInternship
Statistics App downloads statistics data from server (counts of politics mentions on web sites) and displays it in user interface.

Description

Application consists of 5 view controllers: 

1. Login View Controller
2. User Registration View Controller
3. General Statistics View Controller
4. Daily Statistics View Controller
5. Graphic Charts View Controller

Login View Controller checks Login/Password in server database and when found allows login and seeing Statistics Views. In case of wrong Login/Password it shows popup message.
Also Login View Controller has Register button which sends to Registration View Controller.

Registration View Controller allows registering new used with Login/Password. In case of entering credentials of existing user it shows pop up message. Also it validates the email form and length of password (it should be more than 4 characters and contain number). In case of not meeting this email and password requirements controller shows pop up message. When email and password are entered correctly, controller sends them to server to write new user to database. After that the user is sent to login screen where he needs to login.

General Statistic View Controller shows statistics (mentions counts) for all persons in database for picked web site. Web sites should be picked through picker view.
Data are shown in the table.

Daily Statistics View Controller shows statistics (mentions counts) for picked person and picked web sited as well as picked time interval. View controller has four picker views: person picker, web site picker, start and end date picker. After selections are dome in picker, user has to press “Show” button to display data in the table.

Data Load and Storage implemented with three classes: Server Manager and Persistent Manager and Data Manager.
ServerManager loads data from server with AFNetworking protocols.
DataManager saves all loaded data to Core Data.
PersistentManaged decides from which place (server or core date) to get data for certain data inquiry within application.

Graphic Charts View Controller shows graphical representation of statistics. It is implemented by using external library (CocoaPods) called Charts created by D. Gindi 
https://github.com/danielgindi/Charts

[![Demo CountPages alpha](https://j.gifs.com/Anz4OO.gif)](https://youtu.be/yV5MeBYCD_A)
