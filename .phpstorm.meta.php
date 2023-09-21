<?php

namespace PHPSTORM_META {
    override(sql_injection_subst(),
        map([
            "?:" => "cscart_",
            "?n" => "'number'",
            "?i" => "'integer'",
            "?s" => "'string'",
            "?m" => "SET 1=1",
            "?e" => "SET 1=1",
            "?w" => "1=1",
        ]));
}