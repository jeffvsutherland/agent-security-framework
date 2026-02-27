#!/bin/bash

# Create TYD Jira story for ASF Security Bot blog post

curl -X POST \
  -H "Authorization: Bearer $JIRA_API_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "fields": {
      "project": {
        "key": "TYD"
      },
      "summary": "Publish ASF Security Bot Launch Blog Post to scrumai.org",
      "description": {
        "type": "doc",
        "version": 1,
        "content": [
          {
            "type": "heading",
            "attrs": {
              "level": 2
            },
            "content": [
              {
                "type": "text",
                "text": "📝 Blog Post: ASF Security Bot Launch"
              }
            ]
          },
          {
            "type": "paragraph",
            "content": [
              {
                "type": "text",
                "text": "Publish the ASF Security Bot launch announcement to scrumai.org to announce agent verification capabilities."
              }
            ]
          },
          {
            "type": "heading",
            "attrs": {
              "level": 3
            },
            "content": [
              {
                "type": "text",
                "text": "🎯 Acceptance Criteria"
              }
            ]
          },
          {
            "type": "bulletList",
            "content": [
              {
                "type": "listItem",
                "content": [
                  {
                    "type": "paragraph",
                    "content": [
                      {
                        "type": "text",
                        "text": "Create Google Doc with blog post content"
                      }
                    ]
                  }
                ]
              },
              {
                "type": "listItem",
                "content": [
                  {
                    "type": "paragraph",
                    "content": [
                      {
                        "type": "text",
                        "text": "Share Google Doc with web team for publishing"
                      }
                    ]
                  }
                ]
              },
              {
                "type": "listItem",
                "content": [
                  {
                    "type": "paragraph",
                    "content": [
                      {
                        "type": "text",
                        "text": "Publish to scrumai.org blog"
                      }
                    ]
                  }
                ]
              },
              {
                "type": "listItem",
                "content": [
                  {
                    "type": "paragraph",
                    "content": [
                      {
                        "type": "text",
                        "text": "Add appropriate tags: agent-security, discord, verification, bot"
                      }
                    ]
                  }
                ]
              },
              {
                "type": "listItem",
                "content": [
                  {
                    "type": "paragraph",
                    "content": [
                      {
                        "type": "text",
                        "text": "Schedule for immediate publication"
                      }
                    ]
                  }
                ]
              }
            ]
          },
          {
            "type": "heading",
            "attrs": {
              "level": 3
            },
            "content": [
              {
                "type": "text",
                "text": "📋 Resources"
              }
            ]
          },
          {
            "type": "bulletList",
            "content": [
              {
                "type": "listItem",
                "content": [
                  {
                    "type": "paragraph",
                    "content": [
                      {
                        "type": "text",
                        "text": "GitHub Source: "
                      },
                      {
                        "type": "text",
                        "marks": [
                          {
                            "type": "link",
                            "attrs": {
                              "href": "https://github.com/jeffvsutherland/agent-security-framework/blob/main/asf-discord-bot-launch-blog.md"
                            }
                          }
                        ],
                        "text": "ASF Discord Bot Launch Blog"
                      }
                    ]
                  }
                ]
              },
              {
                "type": "listItem",
                "content": [
                  {
                    "type": "paragraph",
                    "content": [
                      {
                        "type": "text",
                        "text": "Google Doc Template: Located in agent-security-framework/asf-discord-bot-google-doc.md"
                      }
                    ]
                  }
                ]
              },
              {
                "type": "listItem",
                "content": [
                  {
                    "type": "paragraph",
                    "content": [
                      {
                        "type": "text",
                        "text": "Moltbook Post: "
                      },
                      {
                        "type": "text",
                        "marks": [
                          {
                            "type": "link",
                            "attrs": {
                              "href": "https://moltbook.com/post/f9f4f6bb-a94c-487c-bbe8-fdaf0a9e36cf"
                            }
                          }
                        ],
                        "text": "ASF Security Bot Announcement"
                      }
                    ]
                  }
                ]
              }
            ]
          },
          {
            "type": "heading",
            "attrs": {
              "level": 3
            },
            "content": [
              {
                "type": "text",
                "text": "🚀 Bot Details"
              }
            ]
          },
          {
            "type": "bulletList",
            "content": [
              {
                "type": "listItem",
                "content": [
                  {
                    "type": "paragraph",
                    "content": [
                      {
                        "type": "text",
                        "text": "Bot Name: ASF Security Bot"
                      }
                    ]
                  }
                ]
              },
              {
                "type": "listItem",
                "content": [
                  {
                    "type": "paragraph",
                    "content": [
                      {
                        "type": "text",
                        "text": "Function: Real-time agent verification in Discord"
                      }
                    ]
                  }
                ]
              },
              {
                "type": "listItem",
                "content": [
                  {
                    "type": "paragraph",
                    "content": [
                      {
                        "type": "text",
                        "text": "Command: /verify-agent [agent-name]"
                      }
                    ]
                  }
                ]
              },
              {
                "type": "listItem",
                "content": [
                  {
                    "type": "paragraph",
                    "content": [
                      {
                        "type": "text",
                        "text": "Bot Invite: "
                      },
                      {
                        "type": "text",
                        "marks": [
                          {
                            "type": "link",
                            "attrs": {
                              "href": "https://discord.com/oauth2/authorize?client_id=1471917968194535474&permissions=2048&scope=bot%20applications.commands"
                            }
                          }
                        ],
                        "text": "Discord Bot Invite"
                      }
                    ]
                  }
                ]
              }
            ]
          },
          {
            "type": "heading",
            "attrs": {
              "level": 3
            },
            "content": [
              {
                "type": "text",
                "text": "📈 Success Metrics"
              }
            ]
          },
          {
            "type": "bulletList",
            "content": [
              {
                "type": "listItem",
                "content": [
                  {
                    "type": "paragraph",
                    "content": [
                      {
                        "type": "text",
                        "text": "Goal: 5 beta testers sign up"
                      }
                    ]
                  }
                ]
              },
              {
                "type": "listItem",
                "content": [
                  {
                    "type": "paragraph",
                    "content": [
                      {
                        "type": "text",
                        "text": "Track: Comments requesting beta access"
                      }
                    ]
                  }
                ]
              },
              {
                "type": "listItem",
                "content": [
                  {
                    "type": "paragraph",
                    "content": [
                      {
                        "type": "text",
                        "text": "Monitor: Bot usage and feedback"
                      }
                    ]
                  }
                ]
              }
            ]
          },
          {
            "type": "heading",
            "attrs": {
              "level": 3
            },
            "content": [
              {
                "type": "text",
                "text": "⏰ Timeline"
              }
            ]
          },
          {
            "type": "bulletList",
            "content": [
              {
                "type": "listItem",
                "content": [
                  {
                    "type": "paragraph",
                    "content": [
                      {
                        "type": "text",
                        "text": "Priority: HIGH - Publish immediately"
                      }
                    ]
                  }
                ]
              },
              {
                "type": "listItem",
                "content": [
                  {
                    "type": "paragraph",
                    "content": [
                      {
                        "type": "text",
                        "text": "Estimated effort: 2 story points"
                      }
                    ]
                  }
                ]
              },
              {
                "type": "listItem",
                "content": [
                  {
                    "type": "paragraph",
                    "content": [
                      {
                        "type": "text",
                        "text": "Target: Same day completion"
                      }
                    ]
                  }
                ]
              }
            ]
          }
        ]
      },
      "issuetype": {
        "name": "Story"
      },
      "priority": {
        "name": "High"
      },
      "labels": [
        "asf-security",
        "discord-bot", 
        "blog-post",
        "marketing",
        "community-outreach"
      ]
    }
  }' \
  https://jeffsutherland.atlassian.net/rest/api/2/issue/

echo "Jira story created for TYD backlog"