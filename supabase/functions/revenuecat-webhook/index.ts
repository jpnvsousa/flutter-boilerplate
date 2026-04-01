/**
 * Supabase Edge Function: revenuecat-webhook
 *
 * Receives webhook events from RevenueCat and updates the user's plan
 * in the profiles table.
 *
 * Deploy: supabase functions deploy revenuecat-webhook
 *
 * Set in RevenueCat dashboard:
 *   Webhook URL: https://<project>.supabase.co/functions/v1/revenuecat-webhook
 *   Authorization header: Bearer <REVENUECAT_WEBHOOK_SECRET>
 *
 * Required Supabase secrets:
 *   supabase secrets set REVENUECAT_WEBHOOK_SECRET=your_secret
 */

import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const supabase = createClient(
  Deno.env.get("SUPABASE_URL")!,
  Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
);

const WEBHOOK_SECRET = Deno.env.get("REVENUECAT_WEBHOOK_SECRET");

// ── Event Types ───────────────────────────────────────────────────────────────
type RevenueCatEventType =
  | "INITIAL_PURCHASE"
  | "RENEWAL"
  | "PRODUCT_CHANGE"
  | "CANCELLATION"
  | "BILLING_ISSUE"
  | "SUBSCRIBER_ALIAS"
  | "EXPIRATION"
  | "UNCANCELLATION";

interface RevenueCatWebhookEvent {
  event: {
    type: RevenueCatEventType;
    app_user_id: string;           // This is the Supabase user ID
    original_app_user_id: string;
    expiration_at_ms?: number;
    cancel_reason?: string;
  };
}

// ── Handler ───────────────────────────────────────────────────────────────────
Deno.serve(async (req: Request) => {
  // ── Auth ────────────────────────────────────────────────────────────────────
  if (WEBHOOK_SECRET) {
    const authHeader = req.headers.get("Authorization");
    const token = authHeader?.replace("Bearer ", "");
    if (token !== WEBHOOK_SECRET) {
      return new Response("Unauthorized", { status: 401 });
    }
  }

  if (req.method !== "POST") {
    return new Response("Method not allowed", { status: 405 });
  }

  let body: RevenueCatWebhookEvent;
  try {
    body = await req.json();
  } catch {
    return new Response("Invalid JSON body", { status: 400 });
  }

  const { event } = body;
  const userId = event.app_user_id;

  console.log(`[RevenueCat] Event: ${event.type} | User: ${userId}`);

  // ── Plan Updates ─────────────────────────────────────────────────────────────
  try {
    switch (event.type) {
      case "INITIAL_PURCHASE":
      case "RENEWAL":
      case "UNCANCELLATION": {
        // User has active subscription → set to PRO
        await supabase
          .from("profiles")
          .update({ plan: "pro" })
          .eq("id", userId);
        console.log(`✅ Set plan=pro for user ${userId}`);
        break;
      }

      case "CANCELLATION": {
        // User cancelled — keep PRO until expiration, RC will send EXPIRATION event
        console.log(`ℹ️ Subscription cancelled for ${userId} (still active until expiry)`);
        break;
      }

      case "EXPIRATION": {
        // Subscription fully expired → downgrade to FREE
        await supabase
          .from("profiles")
          .update({ plan: "free" })
          .eq("id", userId);
        console.log(`⬇️ Set plan=free for user ${userId} (expired)`);
        break;
      }

      case "BILLING_ISSUE": {
        // Payment failed — optionally notify user
        console.log(`⚠️ Billing issue for user ${userId}`);
        break;
      }

      case "PRODUCT_CHANGE": {
        // User changed product/tier — still pro
        await supabase
          .from("profiles")
          .update({ plan: "pro" })
          .eq("id", userId);
        console.log(`🔄 Product changed, plan=pro for user ${userId}`);
        break;
      }

      default:
        console.log(`Unhandled event type: ${event.type}`);
    }

    return new Response(JSON.stringify({ received: true }), {
      status: 200,
      headers: { "Content-Type": "application/json" },
    });
  } catch (error) {
    console.error(`Error processing event:`, error);
    return new Response(JSON.stringify({ error: "Internal server error" }), {
      status: 500,
      headers: { "Content-Type": "application/json" },
    });
  }
});
