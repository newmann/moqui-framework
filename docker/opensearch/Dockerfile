FROM opensearchproject/opensearch:3.4.0

RUN /usr/share/opensearch/bin/opensearch-plugin install --batch \
    https://release.infinilabs.com/analysis-ik/stable/opensearch-analysis-ik-3.4.0.zip \
    && /usr/share/opensearch/bin/opensearch-plugin install --batch opensearch-knn

COPY --chown=opensearch:opensearch ik/IKAnalyzer.cfg.xml \
    /usr/share/opensearch/plugins/analysis-ik/config/IKAnalyzer.cfg.xml
COPY --chown=opensearch:opensearch ik/custom/ \
    /usr/share/opensearch/plugins/analysis-ik/config/custom/
