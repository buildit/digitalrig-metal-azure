curl -u nicholas.galazzo@wipro.com:hhklxwv6nuxkdiekpdeqnfkkqgr2u2snmpvf2brhheh4qateoqdq https://dev.azure.com/rigtest/WebContainerTest/WebContainerTestTeam/_apis/dashboard/dashboards?api-version=5.0-preview.2 -H "Accept: application/json" -H "Content-type: application/json" -X POST -d '{
  "name": "test 3",
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

