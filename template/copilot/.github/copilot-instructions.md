# GitHub Copilot Instructions

This project uses `bake` for task automation and project management. To get better assistance from GitHub Copilot when working on this project:

## Getting Project Context

Use the following command to install project context for AI agents:

```bash
$ bundle install
$ bundle exec bake agent:context:install
```

This command will set up the necessary context files that help AI assistants understand your project structure, dependencies, and conventions.

## Consulting Project Documentation

When working on this project, consult the `agent.md` file for project-specific guidelines, architecture decisions, and development patterns. This file contains curated information that will help you and AI assistants make better decisions aligned with the project's goals and standards.

## Best Practices

- Always run `bundle install && bundle exec bake agent:context:install` when setting up a new development environment
- Refer to `agent.md` before making significant architectural changes
- Keep the context information up-to-date as the project evolves