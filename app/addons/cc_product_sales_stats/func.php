<?php
/*
 *  Get Products grouped by brand
 */
function fn_get_product_orders_per_brands($params): array
{
    if (empty($params['status']) && empty($params['time_to']) && empty($params['time_from'])) {
        return array();
    }

    $condition = $join = $group = $sorting = $limit = '';
    $fields = array(
        ' ?:order_details.product_id',
        '?:order_details.product_code',
        'SUM(?:order_details.amount) amount',
        '?:product_descriptions.product',
        '?:products.amount inventory',
    );

    $FEATURE_BRAND_ID = db_get_field("SELECT feature_id FROM ?:product_features WHERE status='A' AND feature_type='E' AND feature_code='brands' LIMIT 1");

    $join .= " INNER JOIN ?:orders ON ?:order_details.order_id = ?:orders.order_id";
    $join .= db_quote(" LEFT JOIN ?:product_descriptions ON ?:product_descriptions.product_id = ?:order_details.product_id AND ?:product_descriptions.lang_code = ?s",
        CART_LANGUAGE);
    $join .= " INNER JOIN ?:products ON ?:products.product_id = ?:order_details.product_id";

    if ($params['simple_list'] !== 'Y' || !empty($params['brand'])) {

        $fields[] = '?:product_features_values.variant_id';
        $fields[] = '?:product_feature_variant_descriptions.variant';

        $join .= db_quote(" INNER JOIN ?:product_features_values ON ?:product_features_values.product_id = ?:order_details.product_id AND ?:product_features_values.feature_id = ?i AND ?:product_features_values.lang_code=?s",
            $FEATURE_BRAND_ID, CART_LANGUAGE);
        $join .= db_quote(" LEFT JOIN ?:product_feature_variant_descriptions ON ?:product_feature_variant_descriptions.variant_id = ?:product_features_values.variant_id AND ?:product_feature_variant_descriptions.lang_code = ?s",
            CART_LANGUAGE);
    }


    $group .= " GROUP BY ?:order_details.product_id ";

    if (!empty($params['period']) && $params['period'] != 'A') {
        list($params['time_from'], $params['time_to']) = fn_create_periods($params);
        $condition .= db_quote(" AND (?:orders.timestamp >= ?i AND ?:orders.timestamp <= ?i)", $params['time_from'],
            $params['time_to']);
    }

    if (!empty($params['brand'])) {
        $condition .= db_quote(' AND ?:product_features_values.variant_id = ?i', $params['brand']);
    }

    if (!empty($params['status'])) {
        $condition .= db_quote(' AND ?:orders.status IN (?a)', $params['status']);
    }

    if (!empty($params['out_of_stock']) && $params['out_of_stock'] == 'Y') {
        $condition .= ' AND ?:products.amount <= 0';
    }

    if (!empty($params['active_products']) && $params['active_products'] == 'Y') {
        $condition .= ' AND ?:products.status = "A"';
    }

    $sorting = sprintf(
        'ORDER BY %s %s',
        $params['sort_by'] ?? 'amount',
        $params['sort_order'] ?? 'DESC'
    );

    fn_set_hook('get_product_orders_per_brands', $params, $fields, $join, $condition, $group, $sorting, $limit);

    $products = db_get_array('SELECT ' . implode(', ',
            $fields) . " FROM ?:order_details $join WHERE 1 $condition $group $sorting $limit");

    if ($params['simple_list'] !== 'Y') {
        $product_groups = array();
        foreach ($products as $product) {
            $product_groups[$product['variant_id']][] = $product;
        }
    }


    return $product_groups ?? $products;
}
