import { DecodedMessage } from '@xmtp/xmtp-js'
import { JSONSchema7 } from 'json-schema'

export const xmtpMessageSchema: JSONSchema7 = {
  type: 'object',
  properties: {
    id: {
      title: 'Message ID',
      type: 'string',
    },
    senderAddress: {
      type: 'string',
    },
    recipientAddress: {
      type: 'string',
    },
    content: {
      type: 'string',
    },
    contentTopic: {
      type: 'string',
    },
    sent: {
      type: 'string',
    },
    error: {
      type: 'string',
    },
    messageVersion: {
      type: 'string',
    },
    conversation: {
      type: 'object',
      properties: {
        id: {
          type: 'string',
        },
        topic: {
          type: 'string',
        },
        createdAt: {
          type: 'string',
        },
        peerAddress: {
          type: 'string',
        },
      },
    },
  },
}

export function mapXmtpMessageToOutput(message: DecodedMessage) {
  return {
    id: message.id,
    senderAddress: message.senderAddress,
    recipientAddress: message.recipientAddress,
    content: message.content,
    contentTopic: message.contentTopic,
    sent: message.sent,
    error: message.error,
    messageVersion: message.messageVersion,
    conversation: {
      id: message.conversation.context?.conversationId,
      topic: message.conversation.topic,
      createdAt: message.conversation.createdAt,
      peerAddress: message.conversation.peerAddress,
    },
  }
}
