<?php
// backend/api/jwt.php

class JWT {
    // Secret key for signing the tokens. In a production app, this should be in an environment variable.
    private static $secret = 'govassist_super_secret_key_2026_!@#$';

    private static function base64url_encode($data) {
        return rtrim(strtr(base64_encode($data), '+/', '-_'), '=');
    }

    private static function base64url_decode($data) {
        return base64_decode(str_pad(strtr($data, '-_', '+/'), strlen($data) % 4, '=', STR_PAD_RIGHT));
    }

    public static function encode($payload) {
        $header = json_encode(['typ' => 'JWT', 'alg' => 'HS256']);
        
        // Add expiration time (e.g., 24 hours from now) if not set
        if (!isset($payload['exp'])) {
            $payload['exp'] = time() + (24 * 60 * 60); 
        }
        
        $payload = json_encode($payload);

        $base64UrlHeader = self::base64url_encode($header);
        $base64UrlPayload = self::base64url_encode($payload);

        $signature = hash_hmac('sha256', $base64UrlHeader . "." . $base64UrlPayload, self::$secret, true);
        $base64UrlSignature = self::base64url_encode($signature);

        return $base64UrlHeader . "." . $base64UrlPayload . "." . $base64UrlSignature;
    }

    public static function decode($jwt) {
        $tokenParts = explode('.', $jwt);
        
        if (count($tokenParts) != 3) {
            return false;
        }

        $header = base64_decode($tokenParts[0]);
        $payload = base64_decode($tokenParts[1]);
        $signature_provided = $tokenParts[2];

        // Build a signature based on the header and payload using the secret
        $base64UrlHeader = self::base64url_encode($header);
        $base64UrlPayload = self::base64url_encode($payload);
        $signature = hash_hmac('sha256', $base64UrlHeader . "." . $base64UrlPayload, self::$secret, true);
        $base64UrlSignature = self::base64url_encode($signature);

        // Verify it matches the signature provided in the jwt
        if (hash_equals($base64UrlSignature, $signature_provided)) {
            $decoded_payload = json_decode($payload, true);
            
            // Check if token has expired
            if (isset($decoded_payload['exp']) && $decoded_payload['exp'] < time()) {
                return false; // Token expired
            }
            
            return $decoded_payload;
        }

        return false;
    }
}
?>
