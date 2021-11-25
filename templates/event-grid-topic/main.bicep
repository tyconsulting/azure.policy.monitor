param topicName string = 'PolicyStateChanges'

resource evtTopic 'Microsoft.EventGrid/systeTopics@2021-06-01-preview' = {
  name = topicName
  location = 'global'
  properties = {
    source = subscription().id
    topicType = 'Microsoft.PolicyInsights.PolicyStates'
  }
}
