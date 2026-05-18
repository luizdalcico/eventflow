EventFlow

I'm starting to build a new SaaS software called EventFlow.

The main objective is to manage events (wedding, birthdays, corporate events, etc),
in the perspective of the organizer (cerimonailist / cerimonial company).

The app will store all the information about the event, like:
- Type (wedding, adult birthday, children birthday, corporate event)
- Main date
- Start hour
- End hour
- Place + Address
- Owners (for example, in a wedding we have the bride and the groom) with CPF + phone number
- Other dates (for example, a wedding usually has a civil marriage date)
- Estimated number of guests
- Guest list
- Extra hour
- Godparents (in pair or individual) - a reference from guest list

Guest will have:
- Name
- CPF (optional)
- Phone number (optional)

Events will have its providers / professionals, like:
- Photographer
- Buffet
- Filming
- Cake
- Sweets
- Chocolates
- Drinks
- Beer
- Light
- Decoration
- Bouquet
- Women cloth
- Men cloth
- Beauty shop
- Souvenir
- Invitations
- Music / band (can have multiple)

Provider will have:
- Type
- Name
- CNPJ or CPF
- Main contact name
- Phone number

The relation between event and provider will have custom info, like:
- How many sweets
- How many hours contracted
- How many bottles
(depending on provider type)
...

Events will have a checklist for the managers (with date and reminders):
- Call the buffet to organize tables
- Remind the groom to pay a provider
- ...

Events will have a checklist for the owners (with date and reminders):
- Limit date to send the final guest list
- Schedule hair cut until this week
- Dress fitting day
- Rehearsal at church
...

With this structure, the app has the basic information of an event.
Now we are going to have a feature to populate pre-defined templates.
The templates will be just rails views. And they can be exported in PDF or DOCX format.

Technical details:
- rails 8 + ruby 3.4.2
- postgresql
- Use tailwind component
- enums must be always string (not integers in database)
- All view strings must be in portuguese (not need to i18n), but code + tables will be in english.