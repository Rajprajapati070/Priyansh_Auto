PRIYANSH AUTO E.V. DEALERS — Website Package
=============================================

FILES
  index.html          Public dealership website.
  admin.html          Supabase-authenticated website editor.
  supabase-config.js  Public Supabase project URL and anon key.
  supabase-setup.sql  Database, security policies, and image storage setup.

SUPABASE SETUP (REQUIRED TO USE ADMIN EDITING)
  1. Create a Supabase project.
  2. Open the project's SQL Editor, run supabase-setup.sql, and wait for it
     to complete successfully.
  3. In supabase-config.js, set url and anonKey from the project's Connect
     dialog / API settings. The anon (publishable) key is intended for use in
     a browser. NEVER put a service_role or secret key in this website.
  4. In Supabase Authentication settings, disable public sign-ups.
  5. Create the admin user in Authentication > Users. In the SQL Editor, grant
     that user the admin role by running this statement with their email:

       update auth.users
       set raw_app_meta_data = coalesce(raw_app_meta_data, '{}'::jsonb)
         || '{"role":"admin"}'::jsonb
       where email = 'admin@example.com';

     Sign out and sign back in after changing the role so Supabase issues a
     fresh access token. Only users with this role can edit database content
     or upload/delete images; public visitors have read-only access.
  6. Publish the entire folder to your hosting provider.Keep all four files together. Use HTTPS and open the site through its hosted URL (or a local
     web server); browser file:// mode is not suitable for Supabase auth.
  7. Visit /admin.html and sign in with the admin user's email and password.
     Website content and model edits are saved in Supabase and are loaded by
     the public website. Image uploads accept JPG, PNG, WebP, or GIF up to
     5 MB.

The public website remains available with its built-in default content if
Supabase has not been configured. Once connected, run the SQL setup before
publishing or using the editor.

GOOD TO KNOW
  • Photos and fonts load from online services, so an internet connection is
    needed for those assets.
  • Prices are approximate starting ex-showroom figures. Confirm on-road
    prices, subsidies, and stock with the showroom.
  • WhatsApp enquiries use +91 93211 80132. Phone, address, social link,
    Google Business location, site images, and scooter listings can be edited
    in the authenticated admin panel.

© Priyansh Auto E.V. Dealers · Fatehganj Bazar, Allahabad Road, Jaunpur, U.P.
