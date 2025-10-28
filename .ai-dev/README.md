# AI Dev Tasks - Usage Guide for Claude Code

This directory contains the AI Dev Tasks workflow system for structured feature development. The system uses three markdown files to guide AI assistants through a step-by-step development process.

## Overview

The 3-file system breaks down feature development into manageable phases:
1. **Create PRD** - Define what you want to build
2. **Generate Tasks** - Break it down into steps
3. **Process Tasks** - Implement one step at a time

## The Three Files

### 1. create-prd.md
Creates a Product Requirements Document that defines the feature scope, purpose, and requirements.

### 2. generate-tasks.md
Transforms a PRD into granular, actionable implementation tasks with clear sequencing.

### 3. process-task-list.md
Guides the AI to work through tasks sequentially with human checkpoints.

## How to Use with Claude Code

### Step 1: Create a PRD

Start a new conversation and reference the PRD creation file:

```
I want to build [feature description].
Please follow the guidance in .ai-dev/create-prd.md to help me create a PRD.
```

The AI will:
- Ask clarifying questions about your feature
- Generate a structured PRD document
- Save it to `.ai-dev/tasks/0001-prd-[feature-name].md`

### Step 2: Generate Tasks

Once you have a PRD, generate the task list:

```
Please read .ai-dev/tasks/0001-prd-[feature-name].md and follow the process
in .ai-dev/generate-tasks.md to create a task list.
```

The AI will:
- Analyze your PRD
- Review your codebase for existing patterns
- Create high-level parent tasks and ask for approval
- After you say "Go", break down into detailed sub-tasks
- Save to `.ai-dev/tasks/tasks-0001-prd-[feature-name].md`

### Step 3: Process Tasks

Start implementing the feature:

```
Please read .ai-dev/tasks/tasks-0001-prd-[feature-name].md and follow the
process in .ai-dev/process-task-list.md to implement the feature.
```

The AI will:
- Work on one sub-task at a time
- Stop and ask for approval after each sub-task
- Run tests after completing parent tasks
- Commit changes with proper commit messages
- Update the task list with checkmarks as progress is made

## Complete Example Workflow

### Example 1: New Feature

```bash
# 1. Create PRD
You: "I want to add a user profile editing feature. Follow .ai-dev/create-prd.md"
AI: [Asks clarifying questions, creates PRD in .ai-dev/tasks/]

# 2. Generate tasks
You: "Read .ai-dev/tasks/0001-prd-user-profile.md and follow .ai-dev/generate-tasks.md"
AI: [Creates high-level tasks]
You: "Go"
AI: [Breaks down into sub-tasks, saves to .ai-dev/tasks/tasks-0001-prd-user-profile.md]

# 3. Implement
You: "Read .ai-dev/tasks/tasks-0001-prd-user-profile.md and follow .ai-dev/process-task-list.md"
AI: [Completes sub-task 1.1]
You: "yes"
AI: [Completes sub-task 1.2]
You: "yes"
... continues until all tasks done
```

### Example 2: Ansible Role Development

```bash
# 1. Create PRD for new monitoring role
You: "I want to create an Ansible role for Prometheus monitoring. Follow .ai-dev/create-prd.md"
AI: [Asks about monitoring requirements, creates PRD]

# 2. Generate implementation tasks
You: "Read the PRD and follow .ai-dev/generate-tasks.md"
AI: [Generates tasks for role structure, templates, handlers, etc.]

# 3. Implement step by step
You: "Follow .ai-dev/process-task-list.md to implement"
AI: [Implements each task with your approval]
```

## Key Benefits

- **Structured Development**: Clear progression from idea to implementation
- **Quality Control**: Review and approve each step
- **Complexity Management**: Large features broken into small, manageable pieces
- **Better AI Reliability**: Sequential tasks are more reliable than large monolithic requests
- **Progress Tracking**: Visual checkmarks show what's done vs. pending

## Tips for Success

1. **Be Specific**: Provide detailed context when creating PRDs
2. **Review PRDs**: Make sure the PRD captures your requirements before generating tasks
3. **Review High-Level Tasks**: Approve the parent tasks before AI generates sub-tasks
4. **One at a Time**: Stick to the one-sub-task-at-a-time workflow
5. **Test Frequently**: Tests run automatically after each parent task completion
6. **Use for Complex Work**: This system shines for multi-step features, not simple one-off edits

## File Locations

- **Process Files**: `.ai-dev/` (this directory)
- **PRDs**: `.ai-dev/tasks/0001-prd-*.md, 0002-prd-*.md, etc.`
- **Task Lists**: `.ai-dev/tasks/tasks-0001-prd-*.md, tasks-0002-prd-*.md, etc.`

## Quick Reference Commands

### Creating a PRD
```
Follow .ai-dev/create-prd.md to help me create a PRD for [feature description]
```

### Generating Tasks
```
Read .ai-dev/tasks/[prd-file].md and follow .ai-dev/generate-tasks.md
```

### Implementing
```
Read .ai-dev/tasks/tasks-[prd-file].md and follow .ai-dev/process-task-list.md
```

## When NOT to Use This System

- Simple one-line edits or bug fixes
- Quick refactoring of a single function
- Reading/exploring code without changes
- Answering questions about existing code

Use this system for:
- New features with multiple components
- Complex refactoring across multiple files
- Major architectural changes
- Features requiring careful planning and testing

---

**Source**: Based on [ai-dev-tasks](https://github.com/snarktank/ai-dev-tasks) by snarktank
