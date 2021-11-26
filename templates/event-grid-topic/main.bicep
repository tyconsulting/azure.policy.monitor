param topicName string = 'PolicyInsightsTopic'

resource evtTopic 'Microsoft.EventGrid/systemTopics@2021-06-01-preview' = {
  name: topicName
  location: 'global'
  properties: {
    source: subscription().id
    topicType: 'Microsoft.PolicyInsights.PolicyStates'
  }
}

output topicId string = evtTopic.id
