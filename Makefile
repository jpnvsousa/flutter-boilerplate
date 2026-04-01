# Flutter Boilerplate — Makefile
# Usage: make <target>

.PHONY: setup gen test clean build-android build-ios lint check

# ─── Setup ───────────────────────────────────────────────────────────────────
setup: ## Install dependencies and run code generation
	fvm flutter pub get
	make gen
	@echo "✅ Setup complete! Run 'make run' to start the app."

# ─── Code Generation ─────────────────────────────────────────────────────────
gen: ## Run build_runner (Freezed, Riverpod, Injectable, Drift)
	fvm dart run build_runner build --delete-conflicting-outputs

gen-watch: ## Run build_runner in watch mode
	fvm dart run build_runner watch --delete-conflicting-outputs

# ─── Run ─────────────────────────────────────────────────────────────────────
run: ## Run app in debug mode (loads .env.local)
	fvm flutter run \
		--dart-define-from-file=.env.local

run-release: ## Run app in release mode
	fvm flutter run --release \
		--dart-define-from-file=.env.local

# ─── Test ────────────────────────────────────────────────────────────────────
test: ## Run all tests with coverage
	fvm flutter test --coverage
	@echo "✅ Tests complete. Coverage at coverage/lcov.info"

test-unit: ## Run only unit tests
	fvm flutter test test/unit/

test-widget: ## Run only widget tests
	fvm flutter test test/widget/

test-integration: ## Run integration tests
	fvm flutter test test/integration/

# ─── Lint & Quality ──────────────────────────────────────────────────────────
lint: ## Run flutter analyze
	fvm flutter analyze

check: ## Full quality check (lint + test + hardcoded color check)
	@echo "🔍 Running analyzer..."
	fvm flutter analyze
	@echo "🔍 Checking for hardcoded hex colors outside tokens..."
	@! grep -rn "Color(0xFF" lib/features/ lib/shared/ 2>/dev/null || \
		(echo "❌ Hardcoded hex colors found! Use AppTokens instead." && exit 1)
	@echo "🔍 Running tests..."
	fvm flutter test
	@echo "✅ All checks passed!"

# ─── Build ───────────────────────────────────────────────────────────────────
build-android: ## Build Android release AAB
	fvm flutter build appbundle --release \
		--dart-define-from-file=.env.production
	@echo "✅ AAB generated at build/app/outputs/bundle/release/"

build-android-apk: ## Build Android release APK (for testing)
	fvm flutter build apk --release \
		--dart-define-from-file=.env.production
	@echo "✅ APK generated at build/app/outputs/flutter-apk/"

build-ios: ## Build iOS release IPA
	fvm flutter build ipa --release \
		--dart-define-from-file=.env.production
	@echo "✅ IPA generated at build/ios/ipa/"

# ─── Clean ───────────────────────────────────────────────────────────────────
clean: ## Clean build cache and generated files
	fvm flutter clean
	find . -name "*.g.dart" -not -path "*/.*" -delete
	find . -name "*.freezed.dart" -not -path "*/.*" -delete
	find . -name "*.config.dart" -not -path "*/.*" -delete
	@echo "✅ Clean complete."

# ─── Supabase ────────────────────────────────────────────────────────────────
db-push: ## Push migrations to Supabase (local)
	supabase db push

db-reset: ## Reset local Supabase DB and reapply migrations
	supabase db reset

functions-serve: ## Serve Supabase Edge Functions locally
	supabase functions serve

functions-deploy: ## Deploy all Edge Functions to Supabase
	supabase functions deploy revenuecat-webhook
	supabase functions deploy send-notification
	@echo "✅ Edge Functions deployed."

# ─── Help ────────────────────────────────────────────────────────────────────
help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

.DEFAULT_GOAL := help
