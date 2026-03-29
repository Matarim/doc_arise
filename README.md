# DocArise

A multi-tenant visual editor and documentation platform for OpenAPI, AsyncAPI, and Arazzo specifications.

## Project Goal

Build the best-in-class tool for teams to create, edit, version, and publish beautiful, interactive API documentation. The editor must feel as powerful as Swagger Editor / Stoplight Studio while being deeply integrated into a modern Rails multi-tenant application.

**Core Philosophy**
- Drafts are real, reusable revisions (not in-place edits).
- Published revisions are immutable snapshots.
- Semantic versioning (`version` field) is user-controlled.
- Future support for AsyncAPI and Arazzo must reuse the same architecture.

## Current Architecture (final)

- **Organizations → Workspaces → Projects → ApiSpecifications → ApiRevisions**
- `ApiRevision` stores the full spec in `content:jsonb`
- Parsed data lives in `endpoints`, `parameters`, `responses`, `schemas`, `security_schemes`
- `spec_type` column (openapi / asyncapi / arazzo) added for future extensibility

## Current Status (as of March 22, 2026)

**Fully Working**
- Single-page toggle between View mode and Edit mode (Turbo + Stimulus)
- Powerful manual visual editor with full OpenAPI 3.1 support
- Drafts correctly fork from the latest published revision
- "Save as Draft" updates the existing draft (same revision_number)
- "Publish Changes" creates a new revision
- Semantic `version` field (user-editable in editor header)
- Latest **published** revision is shown by default in view mode
- Required flags, nullable, formats, examples, descriptions, etc. now persist correctly
- Clean sidebar — no automatic example path on new revisions
- Deletion of paths is permanent and reliable

**Recent Fixes Applied**
- Double-encoded JSON in hidden field
- Draft always contains full paths from published revision
- Required checkboxes now round-trip correctly
- Turbo Stream navigation fixed
- Empty revisions start with clean sidebar

**Next Priority**
Endpoint-level versioning (individual endpoints can have their own version while the spec moves forward).

**Future Phases (already architected)**
- AsyncAPI support (same revision + parsing pattern)
- Arazzo support (workflow layer on top of OpenAPI)

## Tech Stack
- Rails 8.1 + Ruby 4.0
- PostgreSQL (UUIDs + jsonb)
- Turbo + Stimulus + Tailwind 4 + Haml
- Solid Queue for background jobs
