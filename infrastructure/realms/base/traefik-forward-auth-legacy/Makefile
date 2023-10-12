ca: letsencrypt-stg-root-x1.pem letsencrypt-stg-int-r3.pem
	cat letsencrypt-stg-root-x1.pem > tls.ca
	cat letsencrypt-stg-int-r3.pem >> tls.ca
	
apply: ca
	kubectl create secret generic ca --from-file=tls.ca


letsencrypt-stg-root-x1.pem:
	@wget https://letsencrypt.org/certs/staging/letsencrypt-stg-root-x1.pem


letsencrypt-stg-int-r3.pem:
	@wget https://letsencrypt.org/certs/staging/letsencrypt-stg-int-r3.pem
