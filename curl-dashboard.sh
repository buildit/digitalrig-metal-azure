curl -u ***REMOVED***:***REMOVED*** https://dev.azure.com/rigtest/WebContainerTest/WebContainerTestTeam/_apis/dashboard/dashboards?api-version=5.0-preview.2 -H "Accept: application/json" -H "Content-type: application/json" -X POST -d '{ 
  "name": "test 2", 
  "widgets": [ 
      {
  "name": "Build History",
  "position": {
    "row": 1,
    "column": 1
  },
  "size": {
    "rowSpan": 1,
    "columnSpan": 2
  },
  "settings": null,
  "settingsVersion": {
    "major": 1,
    "minor": 0,
    "patch": 0
  },
  "artifactId": "",
  "url": "https://dev.azure.com/rigtest/e2eb2c17-9bef-4d0c-93a0-650bd0b2e28d/bc952219-8deb-4ab4-bdd8-02c0eef3ca9d/_apis/Dashboard/dashboards/ea5c07ff-9294-49f9-b3cd-55ac9402e64d/Widgets/455aff8b-3582-4345-b80d-5707cc581a22",
  "_links": {
    "self": {
      "href": "https://dev.azure.com/rigtest/e2eb2c17-9bef-4d0c-93a0-650bd0b2e28d/bc952219-8deb-4ab4-bdd8-02c0eef3ca9d/_apis/Dashboard/dashboards/ea5c07ff-9294-49f9-b3cd-55ac9402e64d/Widgets/455aff8b-3582-4345-b80d-5707cc581a22"
    },
    "group": {
      "href": "https://dev.azure.com/rigtest/e2eb2c17-9bef-4d0c-93a0-650bd0b2e28d/bc952219-8deb-4ab4-bdd8-02c0eef3ca9d/_apis/Dashboard/dashboards/ea5c07ff-9294-49f9-b3cd-55ac9402e64d/Widgets"
    },
    "dashboard": {
      "href": "https://dev.azure.com/rigtest/e2eb2c17-9bef-4d0c-93a0-650bd0b2e28d/bc952219-8deb-4ab4-bdd8-02c0eef3ca9d/_apis/Dashboard/Dashboards/ea5c07ff-9294-49f9-b3cd-55ac9402e64d"
    }
  },
  "isEnabled": true,
  "contentUri": null,
  "contributionId": "ms.vss-dashboards-web.Microsoft.VisualStudioOnline.Dashboards.BuildHistogramWidget",
  "typeId": "Microsoft.VisualStudioOnline.Dashboards.BuildHistogramWidget",
  "configurationContributionId": "ms.vss-dashboards-web.Microsoft.VisualStudioOnline.Dashboards.BuildHistogramWidget.Configuration",
  "configurationContributionRelativeId": "Microsoft.VisualStudioOnline.Dashboards.BuildHistogramWidget.Configuration",
  "isNameConfigurable": true,
  "loadingImageUrl": "https://dev.azure.com/rigtest/_static/Widgets/sprintBurndown-buildChartLoading.png"
},
{
  "eTag": "2",
  "name": "Test Results Trend",
  "position": {
    "row": 1,
    "column": 4
  },
  "size": {
    "rowSpan": 2,
    "columnSpan": 2
  },
  "settings": null,
  "settingsVersion": {
    "major": 1,
    "minor": 0,
    "patch": 0
  },
  "artifactId": "",
  "url": "https://dev.azure.com/rigtest/e2eb2c17-9bef-4d0c-93a0-650bd0b2e28d/bc952219-8deb-4ab4-bdd8-02c0eef3ca9d/_apis/Dashboard/dashboards/ea5c07ff-9294-49f9-b3cd-55ac9402e64d/Widgets/de9ba399-5b59-4379-8c51-7c0794bc5d70",
  "_links": {
    "self": {
      "href": "https://dev.azure.com/rigtest/e2eb2c17-9bef-4d0c-93a0-650bd0b2e28d/bc952219-8deb-4ab4-bdd8-02c0eef3ca9d/_apis/Dashboard/dashboards/ea5c07ff-9294-49f9-b3cd-55ac9402e64d/Widgets/de9ba399-5b59-4379-8c51-7c0794bc5d70"
    },
    "group": {
      "href": "https://dev.azure.com/rigtest/e2eb2c17-9bef-4d0c-93a0-650bd0b2e28d/bc952219-8deb-4ab4-bdd8-02c0eef3ca9d/_apis/Dashboard/dashboards/ea5c07ff-9294-49f9-b3cd-55ac9402e64d/Widgets"
    },
    "dashboard": {
      "href": "https://dev.azure.com/rigtest/e2eb2c17-9bef-4d0c-93a0-650bd0b2e28d/bc952219-8deb-4ab4-bdd8-02c0eef3ca9d/_apis/Dashboard/Dashboards/ea5c07ff-9294-49f9-b3cd-55ac9402e64d"
    }
  },
  "isEnabled": true,
  "contentUri": null,
  "contributionId": "ms.vss-test-web.Microsoft.VisualStudioTeamServices.Dashboards.TestResultsTrendWidget",
  "typeId": "Microsoft.VisualStudioTeamServices.Dashboards.TestResultsTrendWidget",
  "configurationContributionId": "ms.vss-test-web.Microsoft.VisualStudioTeamServices.Dashboards.TestResults.TrendWidget.Configuration",
  "configurationContributionRelativeId": "Microsoft.VisualStudioTeamServices.Dashboards.TestResults.TrendWidget.Configuration",
  "isNameConfigurable": true,
  "loadingImageUrl": "https://dev.azure.com/rigtest/_static/Widgets/TestManagement/TestResultTrendLoading.png"
}
  ] 
}'
