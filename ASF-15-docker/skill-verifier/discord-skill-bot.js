#!/usr/bin/env node

// ASF Discord Skill Verification Bot
// Checks OpenClaw/ClawHub skills for security threats
// Similar to agent-verifier but for skills

const { Client, GatewayIntentBits, EmbedBuilder, AttachmentBuilder } = require('discord.js');
const { exec } = require('child_process');
const { promisify } = require('util');
const fs = require('fs').promises;
const path = require('path');
const axios = require('axios');

const execAsync = promisify(exec);

// Configuration
const BOT_TOKEN = process.env.DISCORD_SKILL_BOT_TOKEN;
const SKILL_CHECKER_CHANNEL_ID = process.env.DISCORD_SKILL_CHECKER_CHANNEL_ID || '1234567890';
const VIRUSTOTAL_API_KEY = process.env.VIRUSTOTAL_API_KEY;
const SKILL_CHECKER_SCRIPT = path.join(__dirname, 'skill-checker.sh');

// Risk level colors
const RISK_COLORS = {
    low: 0x00ff00,      // Green
    medium: 0xffff00,    // Yellow
    high: 0xff0000,      // Red
    unknown: 0x808080    // Gray
};

// Risk level emojis
const RISK_EMOJIS = {
    low: '✅',
    medium: '⚠️',
    high: '❌',
    unknown: '❓'
};

// Initialize Discord client
const client = new Client({
    intents: [
        GatewayIntentBits.Guilds,
        GatewayIntentBits.GuildMessages,
        GatewayIntentBits.MessageContent,
        GatewayIntentBits.GuildMembers
    ]
});

// Skill verification cache (24 hour TTL)
const verificationCache = new Map();
const CACHE_TTL = 24 * 60 * 60 * 1000; // 24 hours

// Extract skill identifier from various sources
function extractSkillId(input) {
    // GitHub URL
    const githubMatch = input.match(/github\.com\/([^\/]+\/[^\/]+)/);
    if (githubMatch) return githubMatch[1];
    
    // ClawHub URL
    const clawhubMatch = input.match(/clawhub\.ai\/skills\/([^\/\s]+)/);
    if (clawhubMatch) return clawhubMatch[1];
    
    // NPM package
    const npmMatch = input.match(/@?([^\/\s]+\/[^\/\s]+)$/);
    if (npmMatch) return npmMatch[1];
    
    // Default to input
    return input.trim();
}

// Check if skill was recently verified
function getCachedVerification(skillId) {
    const cached = verificationCache.get(skillId);
    if (cached && Date.now() - cached.timestamp < CACHE_TTL) {
        return cached;
    }
    verificationCache.delete(skillId);
    return null;
}

// Run skill security check
async function checkSkill(skillSource) {
    try {
        // Set environment variables for the script
        const env = {
            ...process.env,
            VIRUSTOTAL_API_KEY: VIRUSTOTAL_API_KEY || '',
            SKILL_CHECK_WORKSPACE: `/tmp/skill-check-${Date.now()}`
        };
        
        // Run the skill checker script
        const { stdout, stderr } = await execAsync(
            `/bin/bash ${SKILL_CHECKER_SCRIPT} "${skillSource}"`,
            { env, timeout: 300000 } // 5 minute timeout
        );
        
        // Parse the results
        const reportMatch = stdout.match(/Full report saved to: (.+)$/m);
        if (!reportMatch) {
            throw new Error('Could not find report file in output');
        }
        
        const reportPath = reportMatch[1].trim();
        const reportContent = await fs.readFile(reportPath, 'utf8');
        const report = JSON.parse(reportContent);
        
        // Clean up report file
        await fs.unlink(reportPath).catch(() => {});
        
        return {
            success: true,
            report,
            output: stdout,
            error: stderr
        };
    } catch (error) {
        console.error('Skill check error:', error);
        return {
            success: false,
            error: error.message,
            output: error.stdout || '',
            stderr: error.stderr || ''
        };
    }
}

// Create Discord embed for skill verification result
function createSkillEmbed(skillId, result) {
    const report = result.report;
    const riskLevel = report?.risk_level || 'unknown';
    const emoji = RISK_EMOJIS[riskLevel];
    const color = RISK_COLORS[riskLevel];
    
    const embed = new EmbedBuilder()
        .setTitle(`${emoji} Skill Security Check: ${skillId}`)
        .setColor(color)
        .setTimestamp();
    
    if (result.success && report) {
        embed.setDescription(report.recommendation || 'Security check completed');
        
        // Risk assessment
        embed.addFields({
            name: 'Risk Level',
            value: `**${riskLevel.toUpperCase()}**`,
            inline: true
        });
        
        embed.addFields({
            name: 'Threats Found',
            value: `**${report.threat_count || 0}**`,
            inline: true
        });
        
        // List threats if any
        if (report.threats && report.threats.length > 0) {
            const threatList = report.threats
                .slice(0, 10) // Limit to 10 threats
                .map(t => `• ${t}`)
                .join('\n');
            
            embed.addFields({
                name: '🚨 Security Concerns',
                value: `\`\`\`\n${threatList}\n\`\`\``,
                inline: false
            });
        }
        
        // Add recommendation
        if (riskLevel === 'high') {
            embed.addFields({
                name: '⛔ Action Required',
                value: '**DO NOT INSTALL THIS SKILL**\n' +
                       'This skill contains suspicious patterns that could compromise security.',
                inline: false
            });
        } else if (riskLevel === 'medium') {
            embed.addFields({
                name: '⚠️ Caution Advised',
                value: 'Review the skill code carefully before installation.\n' +
                       'Consider running in a sandboxed environment.',
                inline: false
            });
        }
        
        // Add ClawHub/VirusTotal links if available
        const links = [];
        if (skillId.includes('/')) {
            links.push(`[View on GitHub](https://github.com/${skillId})`);
        }
        links.push(`[Search on ClawHub](https://clawhub.ai/search?q=${encodeURIComponent(skillId)})`);
        
        if (links.length > 0) {
            embed.addFields({
                name: '🔗 Links',
                value: links.join(' • '),
                inline: false
            });
        }
        
    } else {
        embed.setDescription('❌ Security check failed')
            .addFields({
                name: 'Error',
                value: `\`\`\`\n${result.error || 'Unknown error'}\n\`\`\``,
                inline: false
            });
    }
    
    embed.setFooter({
        text: 'ASF Skill Security Checker • Based on OpenClaw security guidelines'
    });
    
    return embed;
}

// Handle skill check command
async function handleSkillCheck(message, skillSource) {
    const skillId = extractSkillId(skillSource);
    
    // Check cache first
    const cached = getCachedVerification(skillId);
    if (cached) {
        const embed = createSkillEmbed(skillId, cached.result);
        embed.setFooter({ 
            text: embed.data.footer.text + ' • Cached result'
        });
        return message.reply({ embeds: [embed] });
    }
    
    // Send initial response
    const checkingEmbed = new EmbedBuilder()
        .setTitle('🔍 Checking Skill Security...')
        .setDescription(`Analyzing: \`${skillId}\``)
        .setColor(0x3498db)
        .addFields({
            name: 'Status',
            value: '⏳ Running security analysis...\n' +
                   '• Scanning for suspicious patterns\n' +
                   '• Checking for credential theft\n' +
                   '• Analyzing external connections\n' +
                   '• Verifying with VirusTotal',
            inline: false
        });
    
    const reply = await message.reply({ embeds: [checkingEmbed] });
    
    // Run the check
    const result = await checkSkill(skillSource);
    
    // Cache the result
    verificationCache.set(skillId, {
        result,
        timestamp: Date.now()
    });
    
    // Update with results
    const resultEmbed = createSkillEmbed(skillId, result);
    await reply.edit({ embeds: [resultEmbed] });
    
    // If high risk, add warning reaction
    if (result.report?.risk_level === 'high') {
        await reply.react('⛔');
    }
}

// Discord bot event handlers
client.once('ready', () => {
    console.log(`✅ ASF Skill Checker Bot is online as ${client.user.tag}`);
    console.log(`📍 Monitoring channel: ${SKILL_CHECKER_CHANNEL_ID}`);
    
    // Set bot status
    client.user.setActivity('Scanning skills for threats', { type: 'WATCHING' });
});

client.on('messageCreate', async (message) => {
    // Ignore bot messages
    if (message.author.bot) return;
    
    // Check if in the designated channel
    if (message.channel.id !== SKILL_CHECKER_CHANNEL_ID) return;
    
    const content = message.content.toLowerCase();
    
    // Check for skill verification commands
    if (content.startsWith('!checkskill ') || content.startsWith('!check ')) {
        const skillSource = message.content.split(' ').slice(1).join(' ').trim();
        if (skillSource) {
            await handleSkillCheck(message, skillSource);
        } else {
            await message.reply('❌ Please provide a skill to check. Usage: `!checkskill <github-url|package-name>`');
        }
        return;
    }
    
    // Auto-detect skill URLs in messages
    const urlRegex = /(https?:\/\/github\.com\/[^\s]+|https?:\/\/clawhub\.ai\/skills\/[^\s]+)/gi;
    const urls = message.content.match(urlRegex);
    
    if (urls && urls.length > 0) {
        for (const url of urls.slice(0, 3)) { // Limit to 3 URLs per message
            await handleSkillCheck(message, url);
        }
    }
    
    // Help command
    if (content === '!help' || content === '!skillhelp') {
        const helpEmbed = new EmbedBuilder()
            .setTitle('🛡️ ASF Skill Security Checker')
            .setDescription('I analyze OpenClaw/ClawHub skills for security threats')
            .setColor(0x3498db)
            .addFields(
                {
                    name: 'Commands',
                    value: '`!checkskill <source>` - Check a skill for security issues\n' +
                           '`!check <source>` - Short version of checkskill\n' +
                           '`!help` - Show this help message',
                    inline: false
                },
                {
                    name: 'Supported Sources',
                    value: '• GitHub URLs (e.g., `https://github.com/user/skill-name`)\n' +
                           '• ClawHub URLs (e.g., `https://clawhub.ai/skills/weather`)\n' +
                           '• NPM packages (e.g., `@openclaw/skill-weather`)\n' +
                           '• Local paths or direct URLs',
                    inline: false
                },
                {
                    name: 'What I Check For',
                    value: '• Credential theft attempts\n' +
                           '• Obfuscated/encoded payloads\n' +
                           '• Suspicious external connections\n' +
                           '• Dangerous system commands\n' +
                           '• Malicious npm dependencies\n' +
                           '• VirusTotal detection',
                    inline: false
                },
                {
                    name: 'Risk Levels',
                    value: `${RISK_EMOJIS.high} **HIGH** - Do not install\n` +
                           `${RISK_EMOJIS.medium} **MEDIUM** - Review carefully\n` +
                           `${RISK_EMOJIS.low} **LOW** - Appears safe\n` +
                           `${RISK_EMOJIS.unknown} **UNKNOWN** - Check failed`,
                    inline: false
                }
            )
            .setFooter({
                text: 'Based on OpenClaw security best practices'
            });
        
        await message.reply({ embeds: [helpEmbed] });
    }
});

// Error handling
client.on('error', console.error);

// Graceful shutdown
process.on('SIGINT', () => {
    console.log('\n🛑 Shutting down ASF Skill Checker Bot...');
    client.destroy();
    process.exit(0);
});

// Start the bot
if (!BOT_TOKEN) {
    console.error('❌ Error: DISCORD_SKILL_BOT_TOKEN not set in environment');
    process.exit(1);
}

client.login(BOT_TOKEN);