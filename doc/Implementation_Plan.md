# EventFlow Implementation Plan

## Project Overview
EventFlow is a SaaS application for managing events (weddings, birthdays, corporate events) from the organizer's perspective using Rails 8 + Ruby 3.4.2, PostgreSQL, and Tailwind CSS.

## Database Schema Design

### Core Models

#### 1. Events
- `id` (bigint primary key)
- `type` (string enum: wedding, adult_birthday, children_birthday, corporate_event)
- `main_date` (date)
- `start_time` (time)
- `end_time` (time)
- `place` (string)
- `address` (text)
- `estimated_guests` (integer)
- `extra_hours` (decimal)
- `created_at`, `updated_at`

#### 2. Event Owners
- `id` (bigint primary key)
- `event_id` (foreign key)
- `name` (string)
- `cpf` (string)
- `phone_number` (string)
- `role` (string - bride, groom, birthday_person, etc.)
- `created_at`, `updated_at`

#### 3. Event Dates
- `id` (bigint primary key)
- `event_id` (foreign key)
- `date` (date)
- `description` (string - civil_marriage, rehearsal, etc.)
- `created_at`, `updated_at`

#### 4. Guests
- `id` (bigint primary key)
- `event_id` (foreign key)
- `name` (string)
- `cpf` (string, optional)
- `phone_number` (string, optional)
- `is_godparent` (boolean)
- `godparent_pair_id` (foreign key, optional - for pairing godparents)
- `created_at`, `updated_at`

#### 5. Providers
- `id` (bigint primary key)
- `type` (string enum: photographer, buffet, filming, cake, sweets, chocolates, drinks, beer, light, decoration, bouquet, women_cloth, men_cloth, beauty_shop, souvenir, invitations, music_band)
- `name` (string)
- `document` (string - CNPJ or CPF)
- `contact_name` (string)
- `phone_number` (string)
- `created_at`, `updated_at`

#### 6. Event Providers
- `id` (bigint primary key)
- `event_id` (foreign key)
- `provider_id` (foreign key)
- `custom_details` (jsonb - flexible field for provider-specific info)
- `created_at`, `updated_at`

#### 7. Manager Checklists
- `id` (bigint primary key)
- `event_id` (foreign key)
- `task` (string)
- `due_date` (date)
- `completed` (boolean, default: false)
- `reminder_date` (date, optional)
- `created_at`, `updated_at`

#### 8. Owner Checklists
- `id` (bigint primary key)
- `event_id` (foreign key)
- `task` (string)
- `due_date` (date)
- `completed` (boolean, default: false)
- `reminder_date` (date, optional)
- `created_at`, `updated_at`

## Implementation Phases

### Phase 1: Core Models & Database Setup
1. **Database Migrations**
   - Create all core model migrations
   - Add proper indexes and constraints
   - Set up foreign key relationships

2. **Model Classes**
   - Create all ActiveRecord models
   - Define associations and validations
   - Implement string enums
   - Add model methods for business logic

3. **Tailwind CSS Setup**
   - Add Tailwind CSS gem if not already present
   - Configure Tailwind for the application

### Phase 2: Basic CRUD Operations
1. **Controllers & Routes**
   - Events controller (full CRUD)
   - Nested resources for owners, guests, providers
   - Checklist controllers

2. **Views (Portuguese)**
   - Event listing and show pages
   - Event creation and editing forms
   - Guest management interface
   - Provider assignment interface

3. **Forms & Validations**
   - Complex forms with nested attributes
   - Client-side and server-side validation
   - File upload capabilities (if needed)

### Phase 3: Advanced Features
1. **Checklist Management**
   - Manager checklist CRUD
   - Owner checklist CRUD
   - Due date tracking
   - Reminder system

2. **Guest List Management**
   - Import/export functionality
   - Godparent pairing system
   - Guest categorization

3. **Provider Integration**
   - Provider catalog
   - Custom details per provider type
   - Contract tracking

### Phase 4: Template System
1. **Template Engine**
   - Rails view-based templates
   - Dynamic content population
   - Template categories by event type

2. **Export Functionality**
   - PDF generation (using gem like Prawn or WickedPDF)
   - DOCX generation (using gem like Caracal)
   - Template customization interface

### Phase 5: Polish & Deployment
1. **UI/UX Improvements**
   - Responsive design with Tailwind
   - Interactive components
   - Form enhancements

2. **Testing**
   - Model unit tests
   - Service tests

3. **Deployment Setup**
   - Production configuration
   - Database setup
   - Asset pipeline optimization

## Technical Decisions

### Database
- Use PostgreSQL with JSONB for flexible provider details
- Bigint primary keys (Rails default)
- String enums stored as VARCHAR (not integers)

### Frontend
- Tailwind CSS for styling
- Stimulus for JavaScript interactions
- Turbo for SPA-like experience

### Gems to Consider
- `devise` - Authentication
- `kaminari` - Pagination
- `ransack` - Search functionality
- `prawn` or `wicked_pdf` - PDF generation
- `caracal` - DOCX generation
- `image_processing` - Image handling
- `bootsnap` - Performance optimization

### Code Organization
- Service objects for complex business logic
- Concerns for shared model behavior
- Decorators/Presenters for view logic
- Background jobs for heavy operations (exports)

## File Structure
```
app/
├── models/
│   ├── event.rb
│   ├── event_owner.rb
│   ├── event_date.rb
│   ├── guest.rb
│   ├── provider.rb
│   ├── event_provider.rb
│   ├── manager_checklist.rb
│   └── owner_checklist.rb
├── controllers/
│   ├── events_controller.rb
│   ├── guests_controller.rb
│   ├── providers_controller.rb
│   └── checklists_controller.rb
├── views/
│   ├── events/
│   ├── guests/
│   ├── providers/
│   └── templates/
└── services/
    ├── template_service.rb
    ├── export_service.rb
    └── reminder_service.rb
```

## Next Steps (Rails App Already Initialized)
1. Start with Phase 1: Create database migrations for all core models
2. Implement ActiveRecord models with associations and validations
3. Set up Tailwind CSS if not already configured
4. Build basic CRUD interfaces for events
5. Add guest and provider management
6. Implement checklist functionality

This plan provides a solid foundation for building EventFlow while maintaining flexibility for future enhancements and modifications.