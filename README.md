## IUU-Fishing-Detection-DAEN-690-Capstone
### Data Science and Design of a Decision Support Tool to Detect Illegal Fishing
### Lockheed Martin - Stargazer

## **Team:**
- A. Mityushina (Product Owner, Developer) - mityushina.a @ gmail dot com
- S. Jagtap (Scrum Master, Developer)
- A. Mishra (Developer)
- R. Skaddan (Developer)
- E. Taylor (Developer)


## **Abstract**
Illegal, unreported and unregulated (IUU) fishing is a worldwide issue contributing to ecological devastation. It is estimated that 30% of the total fishing yield is due to IUU, making it a top priority for global law enforcement services. This project will develop a decision support system which assists law enforcement in the apprehension of vessels who are partaking in illegal fishing behavior (i.e. IUU). The behavior and data analysis can be extrapolated to other vessel identification scenarios, making this project valuable to other corporations and agencies.
The primary contributor of data comes from the Global Fishing Watch (GFW) but there are other sources which provide critical identification characteristics of vessel. Six data sources are combined to ascertain the following:

All active vessels – defined as a vessel that is in open water. 2) Vessel that is on the known list of offenders – which is defined for the team by the Global Fishing Watch. 3) Vessels that are excused from rules of fishing – i.e. a vessel granted special permission to continue fishing in otherwise illegal conditions. 4) Protected area/Restricted fishing zone given the date and fish type – defined and acknowledged for determining other criteria. 5) AIS Tracking - GPS based system to record location of large vessels. 6) Satellite imagery - visual evidence of a vessel’s status.  

This project builds on existing work completed by a prior GMU engineering team. The regression model identifies a vessel’s behavior and determines if a vessel is fishing or not. Our continuation of the previous project will add new functionality and use the behavior analysis to make a recommendation of which vessels to investigate. The new system is designed as an aid in the decision process but is not meant to replace human decision makers. The success of the design will be judged by its performance against current practices. Specifically, we are evaluating the current cost and resources required for identifying illegal fishing, and comparing the resources required for specific task allocation. The model should outperform the existing practices by 5%. With additional resources, image processing, and live streaming satellite resources model performance can be further improved.

Given the scope and complexity of this problem, the team is focusing on one specific geographical area. By narrowing the region of interest to the Pacific Ocean, this reduces the extraneous data and increases the ability to verify the model before scaling out to additional areas.

The meta-model can be partitioned into two key functions. The first model is a regression model based on AIS location data, speed of the vessel, type of the vessel. This model is able to predict if the vessel is fishing or not fishing. Second, using a light analysis model to identify low light emission from a satellite image. The identification of low light targets assists with vessel identification and tracking. This is an important component as the current knowledge dictates that much of the illegal fishing occurs after the sun has set. The system recognizes and flags a vessel operating with an identified behavior, then the data is enriched by coordinating satellite imagery. This process of vessel identification through AIS tracking, and a confirmation through satellite imagery improves response time therefore increasing the analysis for vehicle apprehension. Thus, the combination of our two models, and the six data sources described above ranks vessels with a priority and generates a queue in which to allocate processing power to image recognition. Vessels identified with a high risk of illegal activity are communicated to the user through a display. The identification of a vessel engaged in illegal behavior is identified through the support tool, but the decision to engage in apprehending the will be left to the individual.


## **Data Resources**

* Global Fishing Watch - Vessell map, AIS tracking, type, protected areas
* Planet Labs - Satellite

## **Prior work - Dependants**

* Website: http://seor.vse.gmu.edu/~klaskey/Capstone/IUU_Fishing/index.html
* Data: https://github.com/iuu-fishing-detection
* Research: https://www.researchgate.net/publication/304711836_Improving_Fishing_Pattern_Detection_from_Satellite_AIS_Using_Data_Mining_and_Machine_Learning
