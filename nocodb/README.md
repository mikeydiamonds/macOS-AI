# NocoDB - No-Code Database Platform

Open-source Airtable alternative that turns any database into a smart spreadsheet interface.

## Features

- Visual database builder with spreadsheet-like interface
- REST & GraphQL APIs auto-generated from your schema
- Rich field types: attachments, links, formulas, ratings, and more
- Forms, views, and sharing capabilities
- Webhooks and automation support

## Configuration

- **URL**: http://nocodb.localhost
- **Database**: PostgreSQL (common-postgres)
- **Cache**: Redis (common-redis)
- **Storage**: Local filesystem for attachments

## Environment Variables

Configure in `.env`:

```env
# Admin credentials (change on first run!)
NC_ADMIN_EMAIL=admin@localhost
NC_ADMIN_PASSWORD=admin123

# Optional: Email notifications
# NC_SMTP_SERVER=smtp.example.com
# NC_SMTP_PORT=587
# NC_SMTP_USERNAME=user@example.com
# NC_SMTP_PASSWORD=your-password
# NC_SMTP_FROM=noreply@localhost
# NC_SMTP_SECURE=false
```

## First-Time Setup

1. Access http://nocodb.localhost
2. Sign in with admin credentials (or change them in `.env`)
3. Create your first base (database)
4. Start building tables and relationships

## Data Storage

- **Application data**: `./data/` (local attachments)
- **Database**: Stored in common-postgres (database: `nocodb`)
- **Cache**: common-redis (namespace: 2)

## Documentation

- [NocoDB Docs](https://docs.nocodb.com/)
- [API Documentation](https://docs.nocodb.com/developer-resources/rest-apis)
