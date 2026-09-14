
## Dev

1. Clone the repository
2. Create a `.env` file based on `.env.template`
3. Run the command `git submodule update --init --recursive` to initialize and rebuild the submodules
4. Run the command `docker compose up --build`


### Steps to create Git Submodules

1. Create a new repository on GitHub
2. Clone the repository to your local machine
3. Add the submodule, where `repository_url` is the repository URL and `directory_name` is the folder name where you want to store the submodule (it must not already exist in the project)
```
git submodule add <repository_url> <directory_name>
```
4. Add the changes to the repository (git add, git commit, git push)  
Example:
```
git add .
git commit -m "Add submodule"
git push
```
5. Initialize and update submodules. When someone clones the repository for the first time, they must run the following command:
```
git submodule update --init --recursive
```
6. To update submodule references:
```
git submodule update --remote
```


## Important

If you are working in a repository that contains submodules, **first update and push** the submodule, and **then** update and push the main repository.

If you do it the other way around, submodule references in the main repository may be lost, and you will need to resolve conflicts.


## Prod
1. Clone the repository.
2. Create a .env file based on the .env.template file.
3. Run the following command

```
docker compose -f docker-compose.prod.yml build
```

## Local Stripe & Hookdeck Setup

The project uses **Stripe Webhooks** and **Hookdeck** to process payment events while running the backend locally.

The local payment flow is:

```text
Stripe
   ↓
Hookdeck
   ↓
localhost:3003/payments/webhook
   ↓
Payments Microservice
   ↓
NATS
   ↓
Orders Microservice
```

### 1. Start the project

After cloning the repository and configuring the environment:

```bash
git submodule update --init --recursive
docker compose up --build
```

Make sure the Payments Microservice is running on port `3003`.

### 2. Authenticate the Stripe CLI

Open a **new terminal** and authenticate the Stripe CLI:

```bash
stripe login
```

Follow the instructions displayed in the terminal and complete the authentication in the browser.

The Stripe CLI authentication is associated with the Stripe account used for the project's test environment.

> The Stripe CLI authentication expires periodically. If the CLI reports that the authentication has expired, run `stripe login` again.

You can verify that the CLI is authenticated by running:

```bash
stripe config --list
```

### 3. Start the Hookdeck local listener

Open another terminal and run:

```bash
hookdeck listen 3003 stripe-localhost --path /payments/webhook
```

Keep this terminal running while testing payments.

The important values are:

```text
Hookdeck connection: stripe-localhost
Local port:           3003
Local path:           /payments/webhook
```

The resulting local endpoint is:

```text
http://localhost:3003/payments/webhook
```

### 4. Verify the Hookdeck connection

Open the Hookdeck Dashboard and locate the connection named:

```text
stripe-localhost
```

Use the **Events** section to verify that webhook events are being received and forwarded successfully.

Useful section:

**Hookdeck Dashboard → Events**

### 5. Verify the Stripe webhook configuration

Open the **Stripe Dashboard** and make sure **Test mode** is enabled.

Navigate to:

```text
Developers / Workbench
    → Webhooks
```

Locate the webhook endpoint configured for this project.

The webhook configuration should forward Stripe payment events through the Hookdeck connection.

The Payments Microservice receives the webhook at:

```text
/payments/webhook
```

### 6. Test a payment

Use the application's API to create an order/payment session.

The Payments Microservice creates a Stripe Checkout session and returns the Checkout URL.

Open the generated Stripe Checkout URL in a browser and complete the payment using Stripe's test environment.

### 7. Verify the payment in Stripe

After completing the test payment, open:

```text
Stripe Dashboard
    → Test mode
    → Payments
```

The new transaction should appear in the list of test payments.

### 8. Verify the webhook event

After Stripe confirms the payment, verify the event in:

```text
Stripe Dashboard
    → Test mode
    → Workbench
    → Webhooks
```

Then check the Hookdeck **Events** section to verify that the event was received and forwarded to the local application.

### 9. Verify the application logs

Check the terminals running the project.

The expected flow is:

```text
Stripe
   ↓
Stripe Webhook
   ↓
Hookdeck
   ↓
Payments Microservice
   ↓
payment.succeeded
   ↓
NATS
   ↓
Orders Microservice
```

The Orders Microservice should then update the corresponding order to:

```text
status = PAID
paid = true
```

and create the associated `OrderReceipt`.

### 10. Useful dashboards

**Hookdeck**

```text
Dashboard → Events
Dashboard → Connections
```

**Stripe**

```text
Test mode → Payments
Test mode → Workbench → Webhooks
```

> The exact URLs and resource IDs in Stripe and Hookdeck may change if the integration is recreated. When setting up the project again, use the dashboards above to locate the corresponding resources instead of relying on project-specific IDs.

### Local setup checklist

Before testing payments, verify:

```text
[ ] Docker Compose services are running
[ ] Payments Microservice is running on port 3003
[ ] Stripe CLI is authenticated
[ ] Hookdeck CLI is running
[ ] Hookdeck connection is named stripe-localhost
[ ] Hookdeck forwards to /payments/webhook
[ ] Stripe webhook is configured
[ ] Stripe is in Test mode
```

### Commands

Stripe CLI authentication:

```bash
stripe login
```

Hookdeck local listener:

```bash
hookdeck listen 3003 stripe-localhost --path /payments/webhook
```

Start the backend:

```bash
docker compose up --build
```