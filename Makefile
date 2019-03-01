create-build-notification:
	@echo "Create Build Notification"
	@scripts/create-build-notification.sh

create-build-dashboard:
	@echo "Create Build Dashboard"
	@scripts/create-build-dashboard.sh

create-parameters-file:
	@echo "Create Parameters File"
	@scripts/create-parameters-file.sh

create-resource-group:
	@echo "Create Resource Group"
	@scripts/create-resource-group.sh

create-build-pipeline:
	@echo "Create Build Pipeline"
	@scripts/createBuildPipeline/create-build-pipeline.sh

create-deploy-pipeline:
	@echo "Create Deploy Pipeline"
	@scripts/create-deploy-pipeline.sh

create-slack-hook:
	@echo "Create Slack Hook"
	@scripts/slack_notifications/create-build-notification.sh

create-dashboard:
	@echo "Create Dashboard"
	@scripts/dashboard/create-build-dashboard.sh

create-populateProject: create-parameters-file create-resource-group create-build-pipeline