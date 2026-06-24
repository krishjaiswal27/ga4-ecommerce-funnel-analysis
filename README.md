# GA4 E-Commerce Session Funnel & Revenue Optimization
*Data source: Google's public GA4 BigQuery sample dataset (Google Merchandise Store, obfuscated). Framed as a stakeholder analysis to practice the full pipeline a real e-commerce analytics team would use.*

## Executive Summary:
E-commerce teams often know their overall conversion rate but not where in the journey users actually drop off, or which fix would move revenue the most. Using BigQuery, PostgreSQL, Power BI, and Python, I built a session-scoped purchase funnel on 3+ months of raw GA4 event data (360K sessions, $362K revenue), tracked users from product view through purchase, and modeled the dollar impact of improving conversion at each stage. After finding that improving the View → Cart step delivers ~$92K more incremental revenue than fixing the funnel's highest-volume stage, I recommend the product team focus on:
1. Reducing friction on the product page (clearer CTA) to lift the 19.5% View → Cart rate
2. Triggering cart-abandonment nudges (email/on-site) for sessions that view but don't add to cart
3. Investigating why Google — the highest-volume source at 128K sessions — converts 3× worse than the store's own referral traffic

### Business Problem:
Most public "funnel analysis" walkthroughs skip a real risk: a funnel built at the user-lifetime level can silently merge two unrelated visits into one fake conversion, making conversion look better (or worse) than it actually is and hiding where the real friction sits. I treated this project as a stakeholder question: where exactly are sessions falling out of the purchase journey, is that drop real or an artifact of how the funnel was measured, and which fix is worth prioritizing first based on revenue impact — not just which stage loses the most users?

<img width="1221" height="633" alt="Image" src="https://github.com/user-attachments/assets/675e6813-0bed-4ccc-acab-1c418824f298" />

### Methodology:
1. **BigQuery** — pulled and flattened 3+ months of raw GA4 event data, unnesting the nested `event_params` array to extract session IDs and build a session-scoped funnel table (one row per visit). This step specifically corrected a lifetime-vs-session conflation issue: an earlier user-level version of this funnel would have counted unrelated visits weeks apart as a single completed conversion.
2. **PostgreSQL** — loaded the flattened funnel and queried overall conversion, device/source/country segment performance, and revenue per session (CTEs, conditional aggregation).
3. **Power BI** — built a 3-page interactive dashboard (executive summary, device analysis, source analysis) so the funnel is browsable by segment, not just a static snapshot.
4. **Python** — ran chi-square significance tests to confirm which segment gaps were real versus noise, then built a revenue-optimization model estimating incremental purchases and revenue from a 1 / 5 / 10 percentage-point conversion lift at each funnel stage.

### Skills:
**BigQuery:** UNNEST on repeated/nested fields, CREATE TABLE AS, conditional aggregation, wildcard table queries  
**PostgreSQL:** CTEs, conditional aggregation, \copy data loading  
**Power BI:** DAX measures, funnel visualization, multi-page dashboard design  
**Python:** Pandas, SciPy (chi-square testing), Matplotlib, funnel and revenue modeling  

### Results & Business Recommendation:

**Overall funnel (360K sessions, Nov 2020 – Jan 2021):**

| Stage | Sessions | Stage-to-Stage |
|---|---|---|
| Sessions | 360K | — |
| Product Viewed | 77K | 21.4% of sessions |
| Added to Cart | 15K | 19.5% of viewed |
| Started Checkout | 11K | 73.3% of cart |
| Purchased | 5K | 45.5% of checkout |
| **Overall conversion** | | **1.35%** |

The steepest drop is at the very top — only 21.4% of sessions ever view a product. But the revenue model showed that is not the highest-priority fix.

**Revenue optimization model:**

A +5 point lift in **View → Cart** generates ~**$92,000** more revenue over the analysis period than the same lift applied to the higher-volume **Session → View** stage. The downstream conversion rate from cart onward is strong enough (73% cart→checkout, 46% checkout→purchase) that gains there carry through to revenue far more efficiently than gains at the top of the funnel.

<img width="790" height="490" alt="image" src="https://github.com/user-attachments/assets/457e7d95-bef6-47e2-8c04-0de0614d37de" />

**Device analysis:**

Mobile converts slightly better (1.39%) than desktop (1.32%) and generates more revenue per session ($1.03 vs $1.00), despite desktop having 46% more sessions. Tablet trails both on conversion (1.30%) and revenue per session ($0.82). The mobile vs. desktop conversion gap is small in absolute terms — running a chi-square significance test before investing in a device-specific fix is recommended.

**Source analysis:**

Google is the highest-volume source (128K sessions, $105K revenue) but converts at just 1.09% — the lowest of any tracked source. The store's own referral traffic (Shop.Googlemerchandisestore.com) converts at 2.03% with the highest average order value ($79.52), despite only 28K sessions. This volume-vs-efficiency gap is the clearest actionable finding: even a modest improvement in Google traffic's conversion rate would have outsized revenue impact given its session volume.

Based on these findings, I recommend:
1. **Product page UX:** Improve the add-to-cart experience to lift the 19.5% View → Cart rate — the highest-ROI stage per the revenue model.
2. **Cart abandonment:** Add retargeting for sessions that view a product but don't add to cart (the largest single drop-off point by volume).
3. **Google traffic quality:** Investigate whether Google campaigns are attracting low-intent traffic, or whether landing page experience is causing the conversion gap vs. direct and referral sources.

### Next Steps:
1. A/B test product-page CTA copy and add-to-cart flow
2. Run chi-square test on mobile vs. desktop and Google vs. other sources to confirm statistical significance before committing budget to segment-specific fixes
3. Extend the funnel one stage further to repeat-purchase/retention — this analysis stops at first purchase
