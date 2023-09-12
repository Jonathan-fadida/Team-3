paste="[default]
aws_access_key_id=ASIAYZ4IP6N3NMVTTUMA
aws_secret_access_key=m4OOCMB4bwCP6+CB5Tw1q+BWJNK4c+4QfiRJ/Bds
aws_session_token=FwoGZXIvYXdzEIL//////////wEaDDwIbTAn8Pnytvx9RSK/AbAC0L79YavNo+zd9U2ux+JakLWostlpkjx5y8HyT75PUGONUZEcpc/d6qNn06+k1jquZxhnJNVDPRdj950Q5LO86XPI+ZVvXo0jOUb7/b9LMjoHzxow+dhm9vGzsPZGzU1SPHDapD9aL19eBFYbg2ZrODjaZlXOClyHe7rV5Jv3SZcXbUCg9AUPw77ZrGpVySdswgYhWyFLQv7gmDdTFqcoo+9Khoe8O0OSbwYNJEM6XXrsrAOzBqYSPKAhQRNCKNGN2KcGMi1ccBmOEORTC/asDKg/c/tIRQn6mBbBdUWgaD2n3RHnXi+wivFcqF93j/iDMyY="

access_key_id=$(echo $paste | grep -oP 'aws_access_key_id=\K[^ ]+')
secret_access_key=$(echo $paste | grep -oP 'aws_secret_access_key=\K[^ ]+')
session_token=$(echo $paste | grep -oP 'aws_session_token=\K[^ ]+')

aws configure set aws_access_key_id "$access_key_id"
aws configure set aws_secret_access_key "$secret_access_key"
aws configure set aws_session_token "$session_token"
