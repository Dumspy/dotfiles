cd "$(dirname "$0")"

if [ -z "$OP_SERVICE_ACCOUNT_TOKEN" ]; then
    if [ -n "$1" ]; then
        service_token="$1"
    else
        echo "Error: No input provided and service token environment variable is missing!" >&2
        exit 1
    fi
    
    export OP_SERVICE_ACCOUNT_TOKEN=$service_token
fi

cat ./secrets.template.yaml | op inject | sops --encrypt --input-type yaml --output-type yaml /dev/stdin > ./secrets.enc.yaml