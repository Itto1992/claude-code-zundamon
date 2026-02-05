.PHONY: help voicevox-up voicevox-down voicevox-logs voicevox-status voicevox-setup

help: ## ヘルプを表示
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}'

# =============================================================================
# VOICEVOX
# =============================================================================

voicevox-up: ## VOICEVOX エンジンを起動
	docker compose up -d voicevox
	@echo "起動中..."
	@until curl -s http://localhost:50021/version > /dev/null 2>&1; do \
		sleep 2; \
		echo "エンジンの起動を待機中..."; \
	done
	@echo "VOICEVOX エンジンが起動しました"
	@curl -s http://localhost:50021/version

voicevox-down: ## VOICEVOX エンジンを停止
	docker compose down

voicevox-logs: ## VOICEVOX エンジンのログを表示
	docker compose logs -f voicevox

voicevox-status: ## VOICEVOX エンジンの状態を確認
	@if curl -s http://localhost:50021/version > /dev/null 2>&1; then \
		echo "状態: 起動中"; \
		echo "バージョン: $$(curl -s http://localhost:50021/version)"; \
	else \
		echo "状態: 停止中"; \
	fi

voicevox-setup: ## VOICEVOX 利用に必要な依存をインストール (Mac)
	@echo "SoX をインストール中..."
	brew install sox || true
	@echo "jq をインストール中..."
	brew install jq || true
	@echo "セットアップ完了"
