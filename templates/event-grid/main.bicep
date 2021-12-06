param eventGridSubName string = 'PolicyInsightsSub'
param topicName string = 'PolicyInsightsTopic'
param functionAppResourceId string = '${resourceGroup().id}/providers/Microsoft.Web/sites/FN-PolicyMonitor'

resource evtTopic 'Microsoft.EventGrid/systemTopics@2021-06-01-preview' = {
  name: topicName
  location: 'global'
  properties: {
    source: subscription().id
    topicType: 'Microsoft.PolicyInsights.PolicyStates'
  }
}

resource evtGridSub 'Microsoft.EventGrid/systemTopics/eventSubscriptions@2021-06-01-preview' = {
  name: concat(evtTopic.name, '/', eventGridSubName)
  properties: {
    eventDeliverySchema: 'EventGridSchema'
    destination: {
      endpointType: 'AzureFunction'
      properties: {
        resourceId: functionAppResourceId
        maxEventsPerBatch: 1
				preferredBatchSizeInKilobytes: 64
      }
    }
    filter: {
      subjectBeginsWith: ''
      subjectEndsWith: ''
      includedEventTypes: [
        'Microsoft.PolicyInsights.PolicyStateChanged'
        'Microsoft.PolicyInsights.PolicyStateCreated'
        'Microsoft.PolicyInsights.PolicyStateDeleted'
      ]
      enableAdvancedFilteringOnArrays: true
    }
  }
}

output evtGridSubId string = evtGridSub.id
