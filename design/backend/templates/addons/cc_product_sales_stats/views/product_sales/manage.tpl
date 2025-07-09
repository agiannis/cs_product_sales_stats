{literal}
<style>
    .object-selector {
        width: 100%;
    }
    @media print {
        .admin-content-wrap .sidebar .sidebar-wrapper {
            width: 359px;
        }
        .navbar-admin-top {
            display: none;
        }
        .actions .title h2 {
            display: none;
        }
        a[href]:after {
            content: none !important;
        }
    }
</style>
{/literal}
{capture name="mainbox"}

    {assign var="c_url" value=$config.current_url|fn_query_remove:"sort_by":"sort_order"}
    {assign var="c_icon" value="<i class=\"exicon-`$search.sort_order_rev`\"></i>"}
    {assign var="c_dummy" value="<i class=\"exicon-dummy\"></i>"}
    {assign var="rev" value=$smarty.request.content_id|default:"product_sales"}

    <form action="{""|fn_url}" method="post" name="userlist_form" id="userlist_form" class="{if $runtime.company_id && !"ULTIMATE"|fn_allowed_for}cm-hide-inputs{/if}">
        <input type="hidden" name="fake" value="1" />
        <input type="hidden" name="user_type" value="{$smarty.request.user_type}" />


        {assign var="c_url" value=$config.current_url|fn_query_remove:"sort_by":"sort_order"}

        {if $brands_products}
            <table style="width: 100%" class="table table-middle">
                <thead>
                <tr>
                    <th style="width: 10%;" class="nowrap">{__("product_code")}</th>
                    <th style="width: 70%;"  class="nowrap">{__("name")}</th>
                    <th style="width: 10%;" class="nowrap">
                        <a class="cm-ajax" href="{"`$c_url`&sort_by=amount&sort_order=`$search.sort_order_rev`"|fn_url}" data-ca-target-id={$rev}>{__("amount")}{if $search.sort_by == "amount"}{$c_icon nofilter}{else}{$c_dummy nofilter}{/if}
                    </th>
                    <th style="width: 10%;" class="nowrap"><a class="cm-ajax" href="{"`$c_url`&sort_by=inventory&sort_order=`$search.sort_order_rev`"|fn_url}" data-ca-target-id={$rev}>{__("inventory")}{if $search.sort_by == "inventory"}{$c_icon nofilter}{else}{$c_dummy nofilter}{/if}</th>
                </tr>
                </thead>
                {foreach from=$brands_products item=brands_product}
                    <tr>
                        <th colspan="4">
                            <h3>{$brands_product[0].variant}</h3></th>
                    </tr>
                    {foreach from=$brands_product item=product}
                        <tr>
                            <td>{$product.product_code}</td>
                            <td><a target="_blank" href="{"products.update&product_id=`$product.product_id`"|fn_url}">{$product.product}</a></td>
                            <td>{$product.amount}</td>
                            <td>{$product.inventory}</td>
                        </tr>
                    {/foreach}
                {/foreach}
            </table>
        {else}
            <p class="no-items">{__("no_data")}</p>
        {/if}


        {capture name="buttons"}
            {if $users}
                {capture name="tools_list"}
                    {if "ULTIMATE"|fn_allowed_for || !$runtime.company_id}
                            <li>{btn type="list" text=__("export_selected") dispatch="dispatch[profiles.export_range]" form="userlist_form"}</li>
                    {/if}
                    <li>{btn type="delete_selected" dispatch="dispatch[profiles.m_delete]" form="userlist_form"}</li>
                {/capture}
                {dropdown content=$smarty.capture.tools_list}
            {/if}
        {/capture}
    </form>
{/capture}

{capture name="buttons"}
    {*{include file="common/daterange_picker.tpl" id="customer_reports_date_picker"
    extra_class="pull-right offset1"
    data_url="customer_reports.view"|fn_url
    result_ids="customer_reports"
    start_date=$time_from end_date=$time_to
    }*}
{/capture}

{capture name="sidebar"}
    <div class="sidebar-row">
        <form action="{""|fn_url}" method="get" name="report_form">
            <h6>{__("search")}</h6>
            {capture name="simple_search"}
                <input type="hidden" name="selected_section" value="">
                <div class="control-group">
                    <label class="control-label" for="brand_select">{$brand_feat_name}:</label>
                    <input type="hidden" name="brand_id" id="brand_id" value="{$brand_id}" />
                    <div class="controls">
                        <input type="hidden" name="brand" value=""/>
                        <div class="object-selector">
                            <select id="brand_select"
                                    class="cm-object-selector"
                                    name="brand"
                                    data-ca-load-via-ajax="true"
                                    data-ca-placeholder="{__("select")}"
                                    data-ca-enable-search="true"
                                    data-ca-enable-images="true"
                                    data-ca-image-width="30"
                                    data-ca-image-height="30"
                                    data-ca-close-on-select="true"
                                    data-ca-page-size="20"
                                    data-ca-data-url="{"product_features.get_variants_list?feature_id=`$brand_feature_id`"|fn_url nofilter}">
                                <option value="{$brand_id}" selected="selected">{$brand_name}</option>
                            </select>
                        </div>
                    </div>
                </div>
                {literal}
                    <script>
                        $(function () {
                            $(window).load(function () {
                                $("#brand_select").val($("#brand_id").val());
                            });

                        });
                    </script>
                {/literal}
                {include file="common/period_selector.tpl" period=$period display="form"}
                <div class="control-group">
                    <label class="control-label">{__("order_status")}:</label>
                    <div class="controls checkbox-list">
                        {include file="common/status.tpl" status=$search.status display="checkboxes" name="status" columns=5}
                    </div>
                </div>
                <div class="control-group">
                    <label class="control-label" >{__("inventory")}:</label>
                    <div class="controls checkbox-list">
                        <label>
                            <input type="hidden" name="out_of_stock" value="N" />
                            <input type="checkbox" name="out_of_stock" value="Y" {if $search.out_of_stock == "Y"}checked="checked"{/if} />
                            {__("cc_product_sales_stats.out_of_stock")}
                        </label>
                    </div>
                </div>
            {/capture}
            {include file="common/advanced_search.tpl"
            no_adv_link=true
            simple_search=$smarty.capture.simple_search
            not_saved=true
            dispatch="product_sales.manage"}
        </form>
    </div>
{/capture}

{include  file="common/mainbox.tpl"
    box_id="product_sales"
    title=__("cc_product_sales_stats.stats_of_product_sales")
    content=$smarty.capture.mainbox
    buttons=$smarty.capture.buttons
    sidebar=$smarty.capture.sidebar
}
