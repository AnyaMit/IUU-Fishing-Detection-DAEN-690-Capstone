## Research Accelerator Program (RAP) 
- To acquire data, one must register with Global Fishing Watch for Research Accelerator Program (RAP) - http://globalfishingwatch.org/research/global-footprint-of-fisheries/

      Terms of Use
      - http://globalfishingwatch.org/terms-of-use/
      Privacy Policy
      - http://globalfishingwatch.org/privacy-policy/


#### *This file describes the file structure of the Data folder.*

### Daily Fishing Effort and Vessel Presence at 100th Degree Resolution by Flag State and GearType, 2012-2016
**Description**
Fishing effort and vessel presence is binned into grid cells 0.01 degrees on a side, and measured in units of hours. The time is calculated by assigning an amount of time to each AIS detection (which is half the time to the previous plus half the time to the next AIS position), and then summing all positions in each grid cell. Data is based on fishing detections of >70,000 unique AIS devices on fishing vessels. Fishing vessels are identified via a neural network classifier and vessel registry databases. The neural net classifies fishing vessels into six categories:

- drifting_longlines: drifting longlines
- purse_seines: purse seines, both pelagic and demersal
- trawlers: trawlers, all types
- fixed_gear: a category that includes set longlines, set gillnets, and pots and traps
- squid_jigger: squid jiggers, mostly large industrial pelagic operating vessels
- other_fishing: a combination of vessels of unknown fishing gear and other, less common gears such as trollers or pole and line

**Materials**
- Documentation
- Zipped CSV by date (2.8 GB)
- Google BigQuery (account required)
- Public Table ID: global-fishing-watch:global_footprint_of_fisheries.fishing_effort
- Google Earth Engine (account Required - signup)
    - Vessel Hours Asset ID: GFW/GFF/V1/vessel_hours
    -  Fishing Hours Asset ID: GFW/GFF/V1/fishing_hours
    
### Daily Fishing Effort at 10th Degree Resolution by MMSI, 2012-2016
**Description**
Fishing effort is binned into grid cells 0.1 degrees on a side, and measured in units of hours. The time is calculated by assigning an amount of time to each AIS detection (which is half the time to the previous plus half the time to the next AIS position). To get information on each mmsi, see Global Fishing Watch data on fishing vessels.

**Materials**
- Documentation
- Zipped CSV by date (0.8 GB)
- Google BigQuery (account required)
- Public Table ID: global-fishing-watch:global_footprint_of_fisheries.fishing_effort_byvessel

### Fishing Vessels Included in Fishing Effort Data
**Description**
This table includes all mmsi that are included in the fishing effort data. It includes all vessels that were identified as fishing vessels by the neural network and which were not identified as non-fishing vessels by registries and manual review. If an mmsi was matched to a fishing vessel on a registry, but the neural net did not classify it as a fishing vessel, it is not included on this list. There is only one row for each mmsi.

**Materials**
- Documentation
- Zipped CSV
- Google BigQuery (account required)
- Public Table ID: global-fishing-watch:global_footprint_of_fisheries.fishing_vessels

### Results of Neural Net Classifier and MMSI Matched to Registries

**Description**
This table includes all mmsi that were matched to a vessel regsitry, were identified through manual review or web searchers, or were classified by the neural network. MMSI that are not included did not have enough activity during our time period (2012 to 2016) to be classified by the neural network (vessels had to have at least 500 positions over a six month period). If an mmsi matched to multiple vessels, that mmsi may be repeated in this table.

**Materials**
- Documentation
- Zipped CSV
- Google BigQuery (account required)
- Public Table ID: global-fishing-watch:global_footprint_of_fisheries.vessels
