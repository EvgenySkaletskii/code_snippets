# Requirements

## Requirements provided by product owners

### Acceptance criteria

Acceptance criteria should be posted in the Azure ticket after finalization.

Acceptance criteria can be tracked as scenarios:

#### Example:

**Scenario: As an admin user, I want to create B2B tiers in the admin panel so that I can place disbursement rules in these tiers.**

Given that I opened the admin panel.
When I click on the B2B tiers button in the header.
Then the B2B tiers page should open with a list of existing B2B tiers.

Given that the B2B tiers page is opened.
When I click on the [Create B2B tier] button.
Then the B2B tiers form should open and contain the next fields: <list of fields>.

Given that the B2B tier form is filled with valid data.
When I save the B2B tier.
Then I should be redirected to the B2B tiers page and view the newly created tier.

### Designs (optional)

Links to the designs.

### Decomposition and modules

Decomposition example:

- **Core logic**
  - Create B2B tiers model and relations.
  - Validations for new tiers (min, max rate).

- **Admin panel**
  - Add B2B tiers page with CRUD logic.
  - Update the Business page - add tiers columns for disbursement rules.

- **Search**
  - Update search to show users only classes within their tier or from tiers below.

### Delivery/deployment notes

Any notes that should be done during/after the release.

### Questions

Any questions that should be clarified with product owners or within the team.
