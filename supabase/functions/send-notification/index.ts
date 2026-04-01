/**
 * Supabase Edge Function: send-notification
 *
 * Sends a push notification to a specific user via Firebase Cloud Messaging.
 *
 * Deploy: supabase functions deploy send-notification
 *
 * Required Supabase secrets:
 *   supabase secrets set FCM_SERVER_KEY=your_firebase_server_key
 *
 * Usage (from server-side or another edge function):
 *   const { data, error } = await supabase.functions.invoke('send-notification', {
 *     body: {
 *       userId: 'uuid',
 *       title: 'Hello!',
 *       body: 'You have a new message',
 *       data: { route: '/tasks/123' }
 *     }
 *   })
 */

import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const supabase = createClient(
  Deno.env.get("SUPABASE_URL")!,
  Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
);

const FCM_SERVER_KEY = Deno.env.get("FCM_SERVER_KEY");
const FCM_URL = "https://fcm.googleapis.com/fcm/send";

interface NotificationPayload {
  userId: string;
  title: string;
  body: string;
  data?: Record<string, string>;
  imageUrl?: string;
}

Deno.serve(async (req: Request) => {
  if (req.method !== "POST") {
    return new Response("Method not allowed", { status: 405 });
  }

  const payload: NotificationPayload = await req.json();

  // ── Get user's FCM token ──────────────────────────────────────────────────
  const { data: profile, error } = await supabase
    .from("profiles")
    .select("fcm_token")
    .eq("id", payload.userId)
    .single();

  if (error || !profile?.fcm_token) {
    return new Response(
      JSON.stringify({ error: "User has no FCM token registered" }),
      { status: 400, headers: { "Content-Type": "application/json" } }
    );
  }

  // ── Send via FCM ──────────────────────────────────────────────────────────
  const fcmPayload = {
    to: profile.fcm_token,
    notification: {
      title: payload.title,
      body: payload.body,
      image: payload.imageUrl,
    },
    data: {
      ...payload.data,
      click_action: "FLUTTER_NOTIFICATION_CLICK",
    },
    priority: "high",
  };

  const response = await fetch(FCM_URL, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      Authorization: `key=${FCM_SERVER_KEY}`,
    },
    body: JSON.stringify(fcmPayload),
  });

  const result = await response.json();

  if (!response.ok || result.failure > 0) {
    console.error("FCM error:", result);
    return new Response(JSON.stringify({ error: "FCM send failed", result }), {
      status: 500,
      headers: { "Content-Type": "application/json" },
    });
  }

  console.log(`✅ Notification sent to user ${payload.userId}`);

  return new Response(JSON.stringify({ success: true, messageId: result.results?.[0]?.message_id }), {
    status: 200,
    headers: { "Content-Type": "application/json" },
  });
});
