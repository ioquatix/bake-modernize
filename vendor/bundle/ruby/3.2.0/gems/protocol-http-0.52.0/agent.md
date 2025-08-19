# Agent

## Context

This section provides links to documentation from installed packages. It is automatically generated and may be updated by running `bake agent:context:install`.

**Important:** Before performing any code, documentation, or analysis tasks, always read and apply the full content of any relevant documentation referenced in the following sections. These context files contain authoritative standards and best practices for documentation, code style, and project-specific workflows. **Do not proceed with any actions until you have read and incorporated the guidance from relevant context files.**

**Setup Instructions:** If the referenced files are not present or if dependencies have been updated, run `bake agent:context:install` to install the latest context files.

### agent-context

Install and manage context files from Ruby gems.

#### [Getting Started](.context/agent-context/getting-started.md)

This guide explains how to use `agent-context`, a tool for discovering and installing contextual information from Ruby gems to help AI agents.

### async

A concurrency framework for Ruby.

#### [Getting Started](.context/async/getting-started.md)

This guide shows how to add async to your project and run code asynchronously.

#### [Scheduler](.context/async/scheduler.md)

This guide gives an overview of how the scheduler is implemented.

#### [Tasks](.context/async/tasks.md)

This guide explains how asynchronous tasks work and how to use them.

#### [Best Practices](.context/async/best-practices.md)

This guide gives an overview of best practices for using Async.

#### [Debugging](.context/async/debugging.md)

This guide explains how to debug issues with programs that use Async.

#### [Thread safety](.context/async/thread-safety.md)

This guide explains thread safety in Ruby, focusing on fibers and threads, common pitfalls, and best practices to avoid problems like data corruption, race conditions, and deadlocks.

### async-service

A service layer for Async.

#### [Getting Started](.context/async-service/getting-started.md)

This guide explains how to get started with `async-service` to create and run services in Ruby.

#### [Service Architecture](.context/async-service/service-architecture.md)

This guide explains the key architectural components of `async-service` and how they work together to provide a clean separation of concerns.

#### [Best Practices](.context/async-service/best-practices.md)

This guide outlines recommended patterns and practices for building robust, maintainable services with `async-service`.

### decode

Code analysis for documentation generation.

#### [Getting Started with Decode](.context/decode/getting-started.md)

The Decode gem provides programmatic access to Ruby code structure and metadata. It can parse Ruby files and extract definitions, comments, and documentation pragmas, enabling code analysis, documentation generation, and other programmatic manipulations of Ruby codebases.

#### [Documentation Coverage](.context/decode/coverage.md)

This guide explains how to test and monitor documentation coverage in your Ruby projects using the Decode gem's built-in bake tasks.

#### [Ruby Documentation](.context/decode/ruby-documentation.md)

This guide covers documentation practices and pragmas supported by the Decode gem for documenting Ruby code. These pragmas provide structured documentation that can be parsed and used to generate API documentation and achieve complete documentation coverage.

#### [Setting Up RBS Types and Steep Type Checking for Ruby Gems](.context/decode/types.md)

This guide covers the process for establishing robust type checking in Ruby gems using RBS and Steep, focusing on automated generation from source documentation and proper validation.

### falcon

A fast, asynchronous, rack-compatible web server.

#### [Getting Started](.context/falcon/getting-started.md)

This guide gives an overview of how to use Falcon for running Ruby web applications.

#### [Rails Integration](.context/falcon/rails-integration.md)

This guide explains how to host Rails applications with Falcon.

#### [Deployment](.context/falcon/deployment.md)

This guide explains how to deploy applications using the Falcon web server. It covers the recommended deployment methods, configuration options, and examples for different environments, including systemd and kubernetes.

#### [Performance Tuning](.context/falcon/performance-tuning.md)

This guide explains the performance characteristics of Falcon.

#### [WebSockets](.context/falcon/websockets.md)

This guide explains how to use WebSockets with Falcon.

#### [Interim Responses](.context/falcon/interim-responses.md)

This guide explains how to use interim responses in Falcon to send early hints to the client.

#### [How It Works](.context/falcon/how-it-works.md)

This guide gives an overview of how Falcon handles an incoming web request.

### sus

A fast and scalable test runner.

#### [Using Sus Testing Framework](.context/sus/usage.md)

Sus is a modern Ruby testing framework that provides a clean, BDD-style syntax for writing tests. It's designed to be fast, simple, and expressive.

#### [Mocking](.context/sus/mocking.md)

There are two types of mocking in sus: `receive` and `mock`. The `receive` matcher is a subset of full mocking and is used to set expectations on method calls, while `mock` can be used to replace method implementations or set up more complex behavior.

#### [Shared Test Behaviors and Fixtures](.context/sus/shared.md)

Sus provides shared test contexts which can be used to define common behaviours or tests that can be reused across one or more test files.

### utopia-project

A project documentation tool based on Utopia.

#### [Getting Started](.context/utopia-project/getting-started.md)

This guide explains how to use `utopia-project` to add documentation to your project.

#### [Documentation Guides](.context/utopia-project/documentation-guidelines.md)

This guide explains how to create and maintain documentation for your project using `utopia-project`.

#### [GitHub Pages Integration](.context/utopia-project/github-pages-integration.md)

This guide shows you how to use `utopia-project` with GitHub Pages to deploy documentation.
