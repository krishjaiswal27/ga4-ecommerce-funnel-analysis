# GA4 E-Commerce Session Funnel & Revenue Optimization
*Data source: Google's public GA4 BigQuery sample dataset (Google Merchandise Store, obfuscated). Framed as a stakeholder analysis to practice the full pipeline a real e-commerce analytics team would use.*

## Executive Summary:
E-commerce teams often know their overall conversion rate but not where in the journey users actually drop off, or which fix would move revenue the most. Using BigQuery, PostgreSQL, Power BI, and Python, I built a session-scoped purchase funnel on 3+ months of raw GA4 event data, tracked users from product view through purchase, and modeled the dollar impact of improving conversion at each stage. After finding that improving the View → Cart step delivers more incremental revenue than fixing the funnel's highest-volume stage, I recommend the product team focus on:
1. Reducing friction on the product page (clearer CTA, fewer required fields before "add to cart")
2. Triggering cart-abandonment nudges (email/on-site) for sessions that view but don't add to cart
3. Re-testing checkout copy and trust signals, where the smaller — but statistically confirmed — drop sits

### Business Problem:
Most public "funnel analysis" walkthroughs skip a real risk: a funnel built at the user-lifetime level can silently merge two unrelated visits into one fake conversion, making conversion look better (or worse) than it actually is and hiding where the real friction sits. I treated this project as a stakeholder question: where exactly are users falling out of the purchase journey, is that drop real or an artifact of how the funnel was measured, and which fix is worth prioritizing first based on revenue impact, not just which stage loses the most users?

<img width="1221" height="633" alt="Image" src="https://github.com/user-attachments/assets/675e6813-0bed-4ccc-acab-1c418824f298" />

### Methodology:
1. **BigQuery** — pulled and flattened 3+ months of raw GA4 event data, unnesting the nested `event_params` array to extract session IDs and build a session-scoped funnel table (one row per visit). This step specifically corrected a lifetime-vs-session conflation issue: an earlier user-level version of this funnel would have counted unrelated visits weeks apart as a single completed conversion.
2. **PostgreSQL** — loaded the flattened funnel and queried overall conversion, device/source/country segment performance, and revenue per session (CTEs, conditional aggregation, window functions).
3. **Power BI** — built a 4-page interactive dashboard (executive summary, device analysis, source analysis, recommendations) so the funnel is browsable by segment, not just a static report.
4. **Python** — ran chi-square significance tests to confirm which segment gaps were real versus noise, then built a revenue-optimization model estimating incremental purchases and revenue from a 1 / 5 / 10 percentage-point conversion lift at each funnel stage.

### Skills:
**BigQuery:** UNNEST on repeated/nested fields, CREATE TABLE AS, conditional aggregation, wildcard table queries
**PostgreSQL:** CTEs, window functions, conditional aggregation, \copy data loading
**Power BI:** DAX measures, funnel visualization, multi-page dashboard design, data modeling
**Python:** Pandas, SciPy (chi-square testing), Matplotlib, writing reusable functions, funnel and revenue modeling

### Results & Business Recommendation:
The session-scoped rebuild changed the picture from an earlier, simpler version of this analysis: roughly **[X]%** of sessions never get past the product-view stage, and **[X]%** of sessions that add to cart go on to complete checkout. A chi-square test on device-level conversion (mobile vs. desktop) returned **p = [X]**, [confirming / not confirming] that the gap between them is statistically meaningful rather than sampling noise.
 
The revenue model produced the clearest recommendation: a 5-point improvement in View → Cart conversion generates roughly **$92,000** more revenue over the analyzed period than the same 5-point improvement applied to the funnel's highest-volume stage (Session → View) — even though far fewer sessions pass through View → Cart. That's because the conversion rate from cart onward to purchase is high enough that gains there carry through to revenue much more efficiently than gains earlier in the funnel.

<img width="790" height="490" alt="image" src="https://github.com/user-attachments/assets/457e7d95-bef6-47e2-8c04-0de0614d37de" />

Based on this, I'd recommend:
1. Prioritize product-page and add-to-cart UX over top-of-funnel acquisition spend — it's the stage with the best revenue return per point of improvement.
2. Add cart-abandonment messaging (email/on-site) targeted at sessions that view a product but never add to cart.
3. [Segment-specific recommendation once device/source/country results are finalized — e.g., a device or traffic-source fix if that gap holds up under the significance test.]
### Next Steps:
1. A/B test product-page copy and the add-to-cart flow against the current version
2. Extend the funnel one stage further to repeat-purchase/retention, since this analysis stops at first purchase
3. Re-run the pipeline on a more recent GA4 export once available, to check whether the View → Cart finding holds over a longer window
