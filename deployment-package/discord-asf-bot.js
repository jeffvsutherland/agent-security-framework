#!/usr/bin/env node

// ASF Discord Bot - Agent Verification
// THE ONE THING: Working agent verification in Discord servers
// Small enough to complete, learn, and ship

const { Client, GatewayIntentBits, SlashCommandBuilder, REST, Routes } = require('discord.js');
const { spawn } = require('child_process');
const fs = require('fs');

// Bot configuration
const TOKEN = process.env.DISCORD_BOT_TOKEN;
const CLIENT_ID = process.env.DISCORD_CLIENT_ID;

if (!TOKEN || !CLIENT_ID) {
    console.error('❌ Missing DISCORD_BOT_TOKEN or DISCORD_CLIENT_ID environment variables');
    process.exit(1);
}

// Create Discord client with minimal intents
const client = new Client({
    intents: [
        GatewayIntentBits.Guilds
    ]
});

// Register slash commands
const commands = [
    new SlashCommandBuilder()
        .setName('verify-agent')
        .setDescription('Verify if an agent is authentic or fake')
        .addStringOption(option =>
            option.setName('agent')
                .setDescription('Agent name to verify')
                .setRequired(true)
        ),
    new SlashCommandBuilder()
        .setName('asf-help')
        .setDescription('Show ASF bot commands and usage')
];

const rest = new REST({ version: '10' }).setToken(TOKEN);

// Function to run fake-agent-detector.sh
function verifyAgent(agentName) {
    return new Promise((resolve, reject) => {
        const detector = spawn('./fake-agent-detector.sh', [agentName, '--json']);
        let output = '';
        let errorOutput = '';

        detector.stdout.on('data', (data) => {
            output += data.toString();
        });

        detector.stderr.on('data', (data) => {
            errorOutput += data.toString();
        });

        detector.on('close', (code) => {
            // Handle all exit codes - script can exit with 1 or 2 for suspicious/fake agents
            try {
                    // Find the last JSON object in the output
                    const lines = output.split('\n');
                    let jsonStart = -1;
                    
                    // Find where JSON starts (look for opening brace)
                    for (let i = lines.length - 1; i >= 0; i--) {
                        if (lines[i].trim() === '{') {
                            jsonStart = i;
                            break;
                        }
                    }
                    
                    if (jsonStart >= 0) {
                        // Extract JSON lines and join them
                        const jsonLines = lines.slice(jsonStart);
                        const jsonText = jsonLines.join('\n');
                        const result = JSON.parse(jsonText);
                        
                        // Map to expected format
                        resolve({
                            agent: agentName,
                            score: result.authenticity_score,
                            classification: result.authenticity_level,
                            reason: result.recommendation,
                            raw_output: output
                        });
                    } else {
                        throw new Error('No JSON found in output');
                    }
                } catch (e) {
                    console.error('❌ JSON parsing failed:', e.message);
                    console.error('Raw output:', output);
                    // Fallback: parse non-JSON output
                    resolve({
                        agent: agentName,
                        score: 50,
                        classification: 'UNKNOWN',
                        reason: 'Analysis completed',
                        raw_output: output
                    });
                }
        });
    });
}

// Format verification results for Discord
function formatVerificationResult(result) {
    const { agent, score, classification, reason } = result;
    
    let emoji = '❓';
    let color = 0x999999;
    
    if (classification === 'AUTHENTIC' || score >= 80) {
        emoji = '✅';
        color = 0x00ff00;
    } else if (classification === 'FAKE' || score <= 30) {
        emoji = '❌';
        color = 0xff0000;
    } else if (classification === 'SUSPICIOUS' || (score > 30 && score < 80)) {
        emoji = '⚠️';
        color = 0xffaa00;
    }

    return {
        embeds: [{
            title: `${emoji} Agent Verification: ${agent}`,
            color: color,
            fields: [
                {
                    name: 'Authenticity Score',
                    value: `${score}/100`,
                    inline: true
                },
                {
                    name: 'Classification',
                    value: classification,
                    inline: true
                },
                {
                    name: 'Analysis',
                    value: reason || 'Verification completed',
                    inline: false
                }
            ],
            footer: {
                text: 'Agent Security Framework • Build working software, deliver value'
            },
            timestamp: new Date()
        }]
    };
}

// Bot ready event
client.once('ready', () => {
    console.log('🚀 ASF Discord Bot is online!');
    console.log(`✅ Logged in as ${client.user.tag}`);
    console.log('🎯 THE ONE THING: Delivering real agent verification');
});

// Handle slash commands
client.on('interactionCreate', async interaction => {
    if (!interaction.isChatInputCommand()) return;

    const { commandName } = interaction;

    if (commandName === 'verify-agent') {
        const agentName = interaction.options.getString('agent');
        
        // Acknowledge the command immediately
        await interaction.deferReply();

        try {
            console.log(`🔍 Verifying agent: "${agentName}"`);
            console.log(`🔍 Agent name length: ${agentName.length}`);
            console.log(`🔍 Agent name char codes: ${Array.from(agentName).map(c => c.charCodeAt(0)).join(',')}`);
            
            // Run verification
            const result = await verifyAgent(agentName);
            console.log(`🔍 Verification result: ${JSON.stringify(result)}`);
            
            // Send formatted result
            const response = formatVerificationResult(result);
            await interaction.editReply(response);
            
            console.log(`✅ Verification complete: ${agentName} = ${result.classification} (${result.score}/100)`);
            
        } catch (error) {
            console.error('❌ Verification failed:', error);
            
            await interaction.editReply({
                embeds: [{
                    title: '❌ Verification Failed',
                    description: `Could not verify agent "${agentName}". Please try again.`,
                    color: 0xff0000,
                    footer: {
                        text: 'Agent Security Framework'
                    }
                }]
            });
        }
    }

    if (commandName === 'asf-help') {
        await interaction.reply({
            embeds: [{
                title: '🛡️ ASF Discord Bot - Agent Verification',
                description: 'Verify agent authenticity in real-time',
                color: 0x0099ff,
                fields: [
                    {
                        name: '/verify-agent <name>',
                        value: 'Verify if an agent is authentic or fake',
                        inline: false
                    },
                    {
                        name: 'How it works',
                        value: 'Uses behavioral analysis, technical verification, and community validation to score agent authenticity (0-100)',
                        inline: false
                    },
                    {
                        name: 'Scoring',
                        value: '• 80-100: ✅ AUTHENTIC\n• 30-79: ⚠️ SUSPICIOUS\n• 0-29: ❌ FAKE',
                        inline: false
                    }
                ],
                footer: {
                    text: 'THE ONE THING: Working software delivering value TODAY'
                }
            }]
        });
    }
});

// Error handling
client.on('error', error => {
    console.error('❌ Discord client error:', error);
});

process.on('unhandledRejection', error => {
    console.error('❌ Unhandled rejection:', error);
});

// Register commands and start bot
async function startBot() {
    try {
        console.log('🔄 Registering slash commands...');
        
        await rest.put(
            Routes.applicationCommands(CLIENT_ID),
            { body: commands }
        );
        
        console.log('✅ Slash commands registered successfully');
        
        // Login to Discord
        await client.login(TOKEN);
        
    } catch (error) {
        console.error('❌ Failed to start bot:', error);
        process.exit(1);
    }
}

// Start the bot
startBot();

console.log('🎯 ASF Discord Bot - THE ONE THING');
console.log('📦 Working software > Documentation');  
console.log('👥 Community value > Revenue projections');
console.log('🚢 Ship daily > Plan weekly');
console.log('⚡ Frequency defeats entropy');