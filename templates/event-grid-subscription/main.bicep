param eventGridSubName string = 'PolicyInsightsSub'
param topicName string = 'PolicyInsightsTopic'
param functionAppResourceId string
resource evtGridSub 'Microsoft.EventGrid/systemTopics/eventSubscriptions@2021-06-01-preview' = {
  name: concat(topicName, '/', eventGridSubName)
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
