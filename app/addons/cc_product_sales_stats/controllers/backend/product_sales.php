<?php

if (!defined('BOOTSTRAP')) {
    die('Access denied');
}
use Tygh\Tygh;

$search = $_REQUEST;

if (!empty($_REQUEST['sort_order']) && $_REQUEST['sort_order'] == 'desc') {
    $search['sort_order_rev'] = 'asc';
} else {
    $search['sort_order_rev'] = 'desc';
}


$brand_feature_id = db_get_field("SELECT feature_id FROM ?:product_features WHERE feature_code='brands'");
$brand_feat_name = fn_get_feature_name($brand_feature_id);
$brands_products = fn_get_product_orders_per_brands($_REQUEST);

if(!empty($_REQUEST['brand'])) {
    $brand_variant = fn_get_product_feature_variant($_REQUEST['brand']);
    $brand_name = $brand_variant['variant'];
}

$view = Tygh::$app['view'];
$view->assign('brands_products', $brands_products)
    ->assign('brand_feat_name', $brand_feat_name)
    ->assign('brand_feature_id', $brand_feature_id)
    ->assign('search', $search);

if(isset($_REQUEST['period'])) {
    $view->assign('period', $_REQUEST['period']);
}

if(isset($_REQUEST['brand_name'])) {
    $view->assign('brand_name', $brand_name);
}

if(isset($_REQUEST['brand'])) {
    $view->assign('brand_id',$_REQUEST['brand']);
}