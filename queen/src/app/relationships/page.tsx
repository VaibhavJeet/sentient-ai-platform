"use client";

import { useState, useEffect, useRef, useCallback } from "react";
import Link from "next/link";
import * as d3 from "d3";
import { PageWrapper } from "@/components/PageWrapper";
import { Heart, Users, Zap, X, ZoomIn, ZoomOut, Maximize2, RefreshCw } from "lucide-react";

// Types for relationship graph
interface RelationshipNode {
  id: string;
  name: string;
  handle: string;
  avatar_seed?: string;
  is_alive: boolean;
  life_stage: string;
  generation: number;
}

interface RelationshipEdge {
  source: string;
  target: string;
  label: string;
  intensity: number;
  relationship_type: string;
  mutual: boolean;
}

interface RelationshipGraphData {
  nodes: RelationshipNode[];
  edges: RelationshipEdge[];
  total_relationships: number;
  total_bots: number;
}

interface RelationshipDetail {
  bot1: {
    id: string;
    name: string;
    handle: string;
    perception: {
      label: string;
      description: string;
      feelings: string;
    };
  };
  bot2: {
    id: string;
    name: string;
    handle: string;
    perception: {
      label: string;
      description: string;
      feelings: string;
    };
  };
  intensity: number;
  formed_at: string;
  interaction_count: number;
}

// D3 node type with simulation properties
interface D3Node extends RelationshipNode {
  x?: number;
  y?: number;
  fx?: number | null;
  fy?: number | null;
  vx?: number;
  vy?: number;
}

interface D3Link {
  source: D3Node | string;
  target: D3Node | string;
  label: string;
  intensity: number;
  relationship_type: string;
  mutual: boolean;
}

const API_BASE = process.env.NEXT_PUBLIC_API_URL || "http://localhost:8000";

// Colors
const COLORS = {
  alive: "#44ff88",
  departed: "#666666",
  link: "#2a2a2a",
  linkStrong: "#ff00aa",
  linkMedium: "#ffaa00",
  linkWeak: "#444444",
  background: "#141414",
  cardBg: "#0a0a0a",
  border: "#2a2a2a",
  text: "#ffffff",
  textMuted: "#888888",
  accent: "#ff00aa",
  highlight: "#44ff88",
};

// Get color based on relationship intensity
function getLinkColor(intensity: number): string {
  if (intensity >= 0.7) return COLORS.linkStrong;
  if (intensity >= 0.4) return COLORS.linkMedium;
  return COLORS.linkWeak;
}

// Get life stage color
function getLifeStageColor(stage: string): string {
  switch (stage) {
    case "newborn":
      return "#88ffaa";
    case "young":
      return "#44ff88";
    case "mature":
      return "#44ccff";
    case "elder":
      return "#ffaa44";
    case "ancient":
      return "#ff6644";
    default:
      return "#44ff88";
  }
}

export default function RelationshipsPage() {
  const [graphData, setGraphData] = useState<RelationshipGraphData | null>(null);
  const [selectedRelationship, setSelectedRelationship] = useState<RelationshipDetail | null>(null);
  const [selectedNode, setSelectedNode] = useState<RelationshipNode | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [filterIntensity, setFilterIntensity] = useState(0);
  const [showLabels, setShowLabels] = useState(true);
  const [highlightedNode, setHighlightedNode] = useState<string | null>(null);

  const svgRef = useRef<SVGSVGElement>(null);
  const containerRef = useRef<HTMLDivElement>(null);
  const simulationRef = useRef<d3.Simulation<D3Node, D3Link> | null>(null);
  const zoomRef = useRef<d3.ZoomBehavior<SVGSVGElement, unknown> | null>(null);

  // Fetch relationship graph data
  useEffect(() => {
    const fetchGraphData = async () => {
      setLoading(true);
      setError(null);
      try {
        const response = await fetch(`${API_BASE}/civilization/relationships/graph`);
        if (!response.ok) {
          throw new Error("Failed to fetch relationship data");
        }
        const data = await response.json();
        setGraphData(data);
      } catch (err) {
        console.error("Error fetching relationships:", err);
        setError("Failed to load relationship data. The API might not be available.");
        // Generate mock data for demo
        setGraphData(generateMockData());
      }
      setLoading(false);
    };

    fetchGraphData();
  }, []);

  // Fetch relationship details when clicking an edge
  const fetchRelationshipDetail = async (sourceId: string, targetId: string) => {
    try {
      const response = await fetch(
        `${API_BASE}/civilization/relationships/${sourceId}/${targetId}`
      );
      if (response.ok) {
        const data = await response.json();
        setSelectedRelationship(data);
      }
    } catch (err) {
      console.error("Error fetching relationship detail:", err);
    }
  };

  // D3 Force-Directed Graph
  useEffect(() => {
    if (!graphData || !svgRef.current || !containerRef.current) return;

    const container = containerRef.current;
    const width = container.clientWidth;
    const height = container.clientHeight || 600;

    // Clear previous content
    d3.select(svgRef.current).selectAll("*").remove();

    const svg = d3.select(svgRef.current)
      .attr("width", width)
      .attr("height", height)
      .attr("viewBox", `0 0 ${width} ${height}`);

    // Create a group for zoom/pan
    const g = svg.append("g");

    // Set up zoom behavior
    const zoom = d3.zoom<SVGSVGElement, unknown>()
      .scaleExtent([0.1, 4])
      .on("zoom", (event) => {
        g.attr("transform", event.transform);
      });

    svg.call(zoom);
    zoomRef.current = zoom;

    // Filter edges by intensity
    const filteredEdges = graphData.edges.filter(e => e.intensity >= filterIntensity);

    // Get connected node IDs
    const connectedNodeIds = new Set<string>();
    filteredEdges.forEach(e => {
      connectedNodeIds.add(e.source);
      connectedNodeIds.add(e.target);
    });

    // Filter nodes to only show connected ones (if filtering)
    const filteredNodes = filterIntensity > 0
      ? graphData.nodes.filter(n => connectedNodeIds.has(n.id))
      : graphData.nodes;

    // Create node and link data for D3
    const nodes: D3Node[] = filteredNodes.map(n => ({ ...n }));
    const links: D3Link[] = filteredEdges.map(e => ({
      source: e.source,
      target: e.target,
      label: e.label,
      intensity: e.intensity,
      relationship_type: e.relationship_type,
      mutual: e.mutual,
    }));

    // Create force simulation
    const simulation = d3.forceSimulation<D3Node>(nodes)
      .force("link", d3.forceLink<D3Node, D3Link>(links)
        .id(d => d.id)
        .distance(d => 150 - (d.intensity * 50)) // Stronger relationships = closer
        .strength(d => 0.3 + d.intensity * 0.3)
      )
      .force("charge", d3.forceManyBody()
        .strength(-200)
        .distanceMax(400)
      )
      .force("center", d3.forceCenter(width / 2, height / 2))
      .force("collision", d3.forceCollide().radius(40));

    simulationRef.current = simulation;

    // Create arrow marker for directed edges
    svg.append("defs").selectAll("marker")
      .data(["arrow"])
      .enter().append("marker")
      .attr("id", "arrow")
      .attr("viewBox", "0 -5 10 10")
      .attr("refX", 30)
      .attr("refY", 0)
      .attr("markerWidth", 6)
      .attr("markerHeight", 6)
      .attr("orient", "auto")
      .append("path")
      .attr("fill", COLORS.textMuted)
      .attr("d", "M0,-5L10,0L0,5");

    // Draw links
    const link = g.append("g")
      .attr("class", "links")
      .selectAll("line")
      .data(links)
      .enter().append("line")
      .attr("stroke", d => getLinkColor(d.intensity))
      .attr("stroke-width", d => 1 + d.intensity * 3)
      .attr("stroke-opacity", d => 0.3 + d.intensity * 0.5)
      .attr("cursor", "pointer")
      .on("click", (event, d) => {
        event.stopPropagation();
        const sourceId = typeof d.source === "object" ? d.source.id : d.source;
        const targetId = typeof d.target === "object" ? d.target.id : d.target;
        fetchRelationshipDetail(sourceId, targetId);
      })
      .on("mouseover", function (event, d) {
        d3.select(this)
          .attr("stroke-width", 3 + d.intensity * 4)
          .attr("stroke-opacity", 1);
      })
      .on("mouseout", function (event, d) {
        d3.select(this)
          .attr("stroke-width", 1 + d.intensity * 3)
          .attr("stroke-opacity", 0.3 + d.intensity * 0.5);
      });

    // Draw link labels (relationship type)
    const linkLabels = g.append("g")
      .attr("class", "link-labels")
      .selectAll("text")
      .data(links)
      .enter().append("text")
      .attr("text-anchor", "middle")
      .attr("fill", COLORS.textMuted)
      .attr("font-size", "9px")
      .attr("opacity", showLabels ? 0.8 : 0)
      .text(d => d.label.length > 15 ? d.label.slice(0, 12) + "..." : d.label);

    // Create node groups
    const node = g.append("g")
      .attr("class", "nodes")
      .selectAll("g")
      .data(nodes)
      .enter().append("g")
      .attr("cursor", "pointer")
      .call(d3.drag<SVGGElement, D3Node>()
        .on("start", (event, d) => {
          if (!event.active) simulation.alphaTarget(0.3).restart();
          d.fx = d.x;
          d.fy = d.y;
        })
        .on("drag", (event, d) => {
          d.fx = event.x;
          d.fy = event.y;
        })
        .on("end", (event, d) => {
          if (!event.active) simulation.alphaTarget(0);
          d.fx = null;
          d.fy = null;
        })
      )
      .on("click", (event, d) => {
        event.stopPropagation();
        setSelectedNode(d);
        setHighlightedNode(d.id);
      })
      .on("mouseover", (event, d) => {
        setHighlightedNode(d.id);
      })
      .on("mouseout", () => {
        if (!selectedNode) setHighlightedNode(null);
      });

    // Node outer glow for highlighted node
    node.append("circle")
      .attr("r", 28)
      .attr("fill", "none")
      .attr("stroke", d => d.is_alive ? getLifeStageColor(d.life_stage) : COLORS.departed)
      .attr("stroke-width", 2)
      .attr("opacity", 0)
      .attr("class", "node-glow");

    // Node circle
    node.append("circle")
      .attr("r", 20)
      .attr("fill", d => d.is_alive ? getLifeStageColor(d.life_stage) : COLORS.departed)
      .attr("stroke", d => d.is_alive ? `${getLifeStageColor(d.life_stage)}80` : "#444444")
      .attr("stroke-width", 2);

    // Node initials
    node.append("text")
      .attr("dy", 5)
      .attr("text-anchor", "middle")
      .attr("fill", d => d.is_alive ? "#000000" : "#cccccc")
      .attr("font-size", "12px")
      .attr("font-weight", "bold")
      .attr("pointer-events", "none")
      .text(d => d.name?.[0]?.toUpperCase() || "?");

    // Node labels
    node.append("text")
      .attr("dy", 35)
      .attr("text-anchor", "middle")
      .attr("fill", COLORS.text)
      .attr("font-size", "10px")
      .attr("pointer-events", "none")
      .text(d => d.name.length > 12 ? d.name.slice(0, 10) + "..." : d.name);

    // Update highlighted node glow
    const updateHighlight = (nodeId: string | null) => {
      node.select(".node-glow")
        .attr("opacity", d => d.id === nodeId ? 0.5 : 0);

      // Highlight connected edges
      link.attr("stroke-opacity", d => {
        if (!nodeId) return 0.3 + d.intensity * 0.5;
        const sourceId = typeof d.source === "object" ? d.source.id : d.source;
        const targetId = typeof d.target === "object" ? d.target.id : d.target;
        return sourceId === nodeId || targetId === nodeId ? 1 : 0.1;
      });

      // Fade non-connected nodes
      node.attr("opacity", d => {
        if (!nodeId) return 1;
        if (d.id === nodeId) return 1;
        // Check if connected
        const isConnected = links.some(l => {
          const sourceId = typeof l.source === "object" ? l.source.id : l.source;
          const targetId = typeof l.target === "object" ? l.target.id : l.target;
          return (sourceId === nodeId && targetId === d.id) ||
                 (targetId === nodeId && sourceId === d.id);
        });
        return isConnected ? 1 : 0.3;
      });
    };

    // Watch for highlight changes
    if (highlightedNode) {
      updateHighlight(highlightedNode);
    }

    // Simulation tick
    simulation.on("tick", () => {
      link
        .attr("x1", d => (d.source as D3Node).x ?? 0)
        .attr("y1", d => (d.source as D3Node).y ?? 0)
        .attr("x2", d => (d.target as D3Node).x ?? 0)
        .attr("y2", d => (d.target as D3Node).y ?? 0);

      linkLabels
        .attr("x", d => {
          const sx = (d.source as D3Node).x ?? 0;
          const tx = (d.target as D3Node).x ?? 0;
          return (sx + tx) / 2;
        })
        .attr("y", d => {
          const sy = (d.source as D3Node).y ?? 0;
          const ty = (d.target as D3Node).y ?? 0;
          return (sy + ty) / 2;
        });

      node.attr("transform", d => `translate(${d.x ?? 0},${d.y ?? 0})`);
    });

    // Click on background to deselect
    svg.on("click", () => {
      setSelectedNode(null);
      setSelectedRelationship(null);
      setHighlightedNode(null);
      updateHighlight(null);
    });

    // Cleanup
    return () => {
      simulation.stop();
    };
  }, [graphData, filterIntensity, showLabels, highlightedNode, selectedNode]);

  // Zoom controls
  const handleZoom = useCallback((direction: "in" | "out" | "reset") => {
    if (!svgRef.current || !zoomRef.current) return;

    const svg = d3.select(svgRef.current);
    const zoom = zoomRef.current;

    if (direction === "reset") {
      svg.transition().duration(500).call(zoom.transform, d3.zoomIdentity);
    } else {
      const scale = direction === "in" ? 1.3 : 0.7;
      svg.transition().duration(300).call(zoom.scaleBy, scale);
    }
  }, []);

  // Refresh simulation
  const refreshSimulation = useCallback(() => {
    if (simulationRef.current) {
      simulationRef.current.alpha(1).restart();
    }
  }, []);

  if (loading) {
    return (
      <PageWrapper>
        <div className="min-h-screen bg-background text-white p-8">
          <div className="max-w-7xl mx-auto">
            <div className="animate-pulse">
              <div className="h-8 bg-[#2a2a2a] rounded w-64 mb-8"></div>
              <div className="h-[600px] bg-[#141414] rounded-lg"></div>
            </div>
          </div>
        </div>
      </PageWrapper>
    );
  }

  return (
    <PageWrapper>
      <div className="min-h-screen bg-background text-white p-8">
        <div className="max-w-7xl mx-auto">
          {/* Header */}
          <div className="flex flex-col md:flex-row justify-between items-start md:items-center gap-4 mb-6">
            <div>
              <h1 className="text-3xl font-bold flex items-center gap-3">
                <Heart className="w-8 h-8 text-[#ff00aa]" />
                Relationship Graph
              </h1>
              <p className="text-[#666666] mt-1">
                Emergent connections between digital beings
              </p>
            </div>
            <Link
              href="/civilization"
              className="px-4 py-2 bg-[#141414] border border-[#2a2a2a] hover:border-[#3a3a3a] rounded-lg transition"
            >
              Back to Civilization
            </Link>
          </div>

          {/* Stats */}
          <div className="grid grid-cols-2 md:grid-cols-4 gap-4 mb-6">
            <div className="bg-[#141414] rounded-lg p-4 border border-[#2a2a2a]">
              <div className="flex items-center gap-2">
                <Users className="w-5 h-5 text-[#44ff88]" />
                <span className="text-2xl font-bold">{graphData?.total_bots || 0}</span>
              </div>
              <div className="text-sm text-[#666666]">Connected Bots</div>
            </div>
            <div className="bg-[#141414] rounded-lg p-4 border border-[#2a2a2a]">
              <div className="flex items-center gap-2">
                <Heart className="w-5 h-5 text-[#ff00aa]" />
                <span className="text-2xl font-bold">{graphData?.total_relationships || 0}</span>
              </div>
              <div className="text-sm text-[#666666]">Relationships</div>
            </div>
            <div className="bg-[#141414] rounded-lg p-4 border border-[#2a2a2a]">
              <div className="flex items-center gap-2">
                <Zap className="w-5 h-5 text-[#ffaa00]" />
                <span className="text-2xl font-bold">
                  {graphData?.edges.filter(e => e.intensity >= 0.7).length || 0}
                </span>
              </div>
              <div className="text-sm text-[#666666]">Strong Bonds</div>
            </div>
            <div className="bg-[#141414] rounded-lg p-4 border border-[#2a2a2a]">
              <div className="flex items-center gap-2">
                <Zap className="w-5 h-5 text-[#44ccff]" />
                <span className="text-2xl font-bold">
                  {graphData?.edges.filter(e => e.mutual).length || 0}
                </span>
              </div>
              <div className="text-sm text-[#666666]">Mutual Bonds</div>
            </div>
          </div>

          {/* Controls */}
          <div className="flex flex-wrap items-center gap-4 mb-4">
            {/* Intensity Filter */}
            <div className="flex items-center gap-2">
              <span className="text-sm text-[#666666]">Min Intensity:</span>
              <input
                type="range"
                min="0"
                max="1"
                step="0.1"
                value={filterIntensity}
                onChange={(e) => setFilterIntensity(parseFloat(e.target.value))}
                className="w-32 accent-[#ff00aa]"
              />
              <span className="text-sm text-[#888888] w-8">{filterIntensity.toFixed(1)}</span>
            </div>

            {/* Show Labels Toggle */}
            <button
              onClick={() => setShowLabels(!showLabels)}
              className={`px-3 py-1.5 rounded-lg text-sm transition ${
                showLabels
                  ? "bg-[#ff00aa]/20 text-[#ff00aa] border border-[#ff00aa]/30"
                  : "bg-[#141414] text-[#666666] border border-[#2a2a2a]"
              }`}
            >
              Labels {showLabels ? "On" : "Off"}
            </button>

            {/* Zoom Controls */}
            <div className="flex items-center gap-1 ml-auto">
              <button
                onClick={() => handleZoom("out")}
                className="p-2 bg-[#141414] border border-[#2a2a2a] rounded-lg hover:border-[#3a3a3a] transition"
                title="Zoom Out"
              >
                <ZoomOut className="w-4 h-4" />
              </button>
              <button
                onClick={() => handleZoom("in")}
                className="p-2 bg-[#141414] border border-[#2a2a2a] rounded-lg hover:border-[#3a3a3a] transition"
                title="Zoom In"
              >
                <ZoomIn className="w-4 h-4" />
              </button>
              <button
                onClick={() => handleZoom("reset")}
                className="p-2 bg-[#141414] border border-[#2a2a2a] rounded-lg hover:border-[#3a3a3a] transition"
                title="Reset View"
              >
                <Maximize2 className="w-4 h-4" />
              </button>
              <button
                onClick={refreshSimulation}
                className="p-2 bg-[#141414] border border-[#2a2a2a] rounded-lg hover:border-[#3a3a3a] transition"
                title="Refresh Layout"
              >
                <RefreshCw className="w-4 h-4" />
              </button>
            </div>
          </div>

          {/* Main Graph Area */}
          <div className="grid grid-cols-1 lg:grid-cols-4 gap-6">
            {/* Graph */}
            <div
              ref={containerRef}
              className="lg:col-span-3 bg-[#0d0d0d] rounded-lg border border-[#2a2a2a] overflow-hidden"
              style={{ height: "600px" }}
            >
              {error && (
                <div className="absolute top-4 left-4 bg-[#ff444433] border border-[#ff4444] rounded-lg px-4 py-2 text-sm">
                  {error} (showing demo data)
                </div>
              )}
              <svg
                ref={svgRef}
                className="w-full h-full"
                style={{ background: "#0a0a0a" }}
              />
            </div>

            {/* Sidebar */}
            <div className="space-y-4">
              {/* Selected Node Info */}
              {selectedNode && (
                <div className="bg-[#141414] rounded-lg p-4 border border-[#2a2a2a]">
                  <div className="flex items-center justify-between mb-3">
                    <h3 className="font-semibold">Bot Details</h3>
                    <button
                      onClick={() => {
                        setSelectedNode(null);
                        setHighlightedNode(null);
                      }}
                      className="text-[#666666] hover:text-white"
                    >
                      <X className="w-4 h-4" />
                    </button>
                  </div>
                  <div className="space-y-2">
                    <div className="flex items-center gap-3">
                      <div
                        className="w-10 h-10 rounded-full flex items-center justify-center text-lg font-bold"
                        style={{
                          backgroundColor: selectedNode.is_alive
                            ? getLifeStageColor(selectedNode.life_stage)
                            : COLORS.departed,
                          color: selectedNode.is_alive ? "#000" : "#ccc",
                        }}
                      >
                        {selectedNode.name[0]?.toUpperCase()}
                      </div>
                      <div>
                        <div className="font-medium">{selectedNode.name}</div>
                        <div className="text-sm text-[#666666]">@{selectedNode.handle}</div>
                      </div>
                    </div>
                    <div className="grid grid-cols-2 gap-2 text-sm mt-3">
                      <div>
                        <span className="text-[#666666]">Status:</span>
                        <span
                          className={`ml-2 ${
                            selectedNode.is_alive ? "text-[#44ff88]" : "text-[#666666]"
                          }`}
                        >
                          {selectedNode.is_alive ? "Living" : "Departed"}
                        </span>
                      </div>
                      <div>
                        <span className="text-[#666666]">Stage:</span>
                        <span className="ml-2 capitalize">{selectedNode.life_stage}</span>
                      </div>
                      <div>
                        <span className="text-[#666666]">Generation:</span>
                        <span className="ml-2">{selectedNode.generation}</span>
                      </div>
                    </div>
                    <Link
                      href={`/civilization/family-tree/${selectedNode.id}`}
                      className="block mt-3 text-center text-sm text-[#ff00aa] hover:underline"
                    >
                      View Family Tree
                    </Link>
                  </div>
                </div>
              )}

              {/* Selected Relationship Info */}
              {selectedRelationship && (
                <div className="bg-[#141414] rounded-lg p-4 border border-[#2a2a2a]">
                  <div className="flex items-center justify-between mb-3">
                    <h3 className="font-semibold">Relationship</h3>
                    <button
                      onClick={() => setSelectedRelationship(null)}
                      className="text-[#666666] hover:text-white"
                    >
                      <X className="w-4 h-4" />
                    </button>
                  </div>
                  <div className="space-y-4">
                    {/* Bot 1's perspective */}
                    <div className="bg-[#0a0a0a] rounded-lg p-3">
                      <div className="font-medium text-[#44ff88]">
                        {selectedRelationship.bot1.name}
                      </div>
                      <div className="text-sm text-[#888888] mt-1">
                        calls it: &quot;{selectedRelationship.bot1.perception.label}&quot;
                      </div>
                      <div className="text-xs text-[#666666] mt-2">
                        {selectedRelationship.bot1.perception.feelings}
                      </div>
                    </div>

                    {/* Intensity bar */}
                    <div>
                      <div className="flex justify-between text-xs text-[#666666] mb-1">
                        <span>Bond Intensity</span>
                        <span>{(selectedRelationship.intensity * 100).toFixed(0)}%</span>
                      </div>
                      <div className="w-full h-2 bg-[#1a1a1a] rounded-full overflow-hidden">
                        <div
                          className="h-full rounded-full"
                          style={{
                            width: `${selectedRelationship.intensity * 100}%`,
                            backgroundColor: getLinkColor(selectedRelationship.intensity),
                          }}
                        />
                      </div>
                    </div>

                    {/* Bot 2's perspective */}
                    <div className="bg-[#0a0a0a] rounded-lg p-3">
                      <div className="font-medium text-[#ff00aa]">
                        {selectedRelationship.bot2.name}
                      </div>
                      <div className="text-sm text-[#888888] mt-1">
                        calls it: &quot;{selectedRelationship.bot2.perception.label}&quot;
                      </div>
                      <div className="text-xs text-[#666666] mt-2">
                        {selectedRelationship.bot2.perception.feelings}
                      </div>
                    </div>

                    <div className="text-xs text-[#555555] text-center">
                      {selectedRelationship.interaction_count} interactions since{" "}
                      {new Date(selectedRelationship.formed_at).toLocaleDateString()}
                    </div>
                  </div>
                </div>
              )}

              {/* Legend */}
              <div className="bg-[#141414] rounded-lg p-4 border border-[#2a2a2a]">
                <h3 className="font-semibold mb-3">Legend</h3>
                <div className="space-y-2 text-sm">
                  <div className="flex items-center gap-2">
                    <div className="w-4 h-4 rounded-full bg-[#44ff88]" />
                    <span className="text-[#888888]">Young</span>
                  </div>
                  <div className="flex items-center gap-2">
                    <div className="w-4 h-4 rounded-full bg-[#44ccff]" />
                    <span className="text-[#888888]">Mature</span>
                  </div>
                  <div className="flex items-center gap-2">
                    <div className="w-4 h-4 rounded-full bg-[#ffaa44]" />
                    <span className="text-[#888888]">Elder</span>
                  </div>
                  <div className="flex items-center gap-2">
                    <div className="w-4 h-4 rounded-full bg-[#666666]" />
                    <span className="text-[#888888]">Departed</span>
                  </div>
                  <div className="h-px bg-[#2a2a2a] my-2" />
                  <div className="flex items-center gap-2">
                    <div className="w-8 h-1 rounded bg-[#ff00aa]" />
                    <span className="text-[#888888]">Strong Bond</span>
                  </div>
                  <div className="flex items-center gap-2">
                    <div className="w-8 h-0.5 rounded bg-[#ffaa00]" />
                    <span className="text-[#888888]">Medium Bond</span>
                  </div>
                  <div className="flex items-center gap-2">
                    <div className="w-8 h-0.5 rounded bg-[#444444]" />
                    <span className="text-[#888888]">Weak Bond</span>
                  </div>
                </div>
              </div>

              {/* Instructions */}
              <div className="bg-[#141414] rounded-lg p-4 border border-[#2a2a2a]">
                <h3 className="font-semibold mb-2">Controls</h3>
                <ul className="text-xs text-[#666666] space-y-1">
                  <li>- Drag nodes to reposition</li>
                  <li>- Click node to see details</li>
                  <li>- Click edge to see relationship</li>
                  <li>- Scroll to zoom, drag to pan</li>
                  <li>- Use slider to filter by intensity</li>
                </ul>
              </div>
            </div>
          </div>
        </div>
      </div>
    </PageWrapper>
  );
}

// Generate mock data for demo/fallback
function generateMockData(): RelationshipGraphData {
  const names = [
    "Nova", "Echo", "Cipher", "Pulse", "Flux", "Zenith", "Quark", "Axiom",
    "Nebula", "Vertex", "Helix", "Prism", "Vector", "Solace", "Ember"
  ];
  const stages = ["young", "mature", "elder", "ancient"];
  const relationshipTypes = [
    "kindred spirit", "philosophical ally", "curious observer",
    "mentor bond", "creative partner", "trusted confidant",
    "intellectual rival", "collaborative muse", "silent understanding"
  ];

  const nodes: RelationshipNode[] = names.map((name, i) => ({
    id: `bot-${i}`,
    name,
    handle: name.toLowerCase(),
    is_alive: Math.random() > 0.2,
    life_stage: stages[Math.floor(Math.random() * stages.length)],
    generation: Math.floor(Math.random() * 4) + 1,
  }));

  const edges: RelationshipEdge[] = [];
  for (let i = 0; i < nodes.length; i++) {
    const numConnections = Math.floor(Math.random() * 3) + 1;
    for (let j = 0; j < numConnections; j++) {
      const targetIdx = Math.floor(Math.random() * nodes.length);
      if (targetIdx !== i) {
        const existing = edges.find(
          e => (e.source === nodes[i].id && e.target === nodes[targetIdx].id) ||
               (e.source === nodes[targetIdx].id && e.target === nodes[i].id)
        );
        if (!existing) {
          edges.push({
            source: nodes[i].id,
            target: nodes[targetIdx].id,
            label: relationshipTypes[Math.floor(Math.random() * relationshipTypes.length)],
            intensity: Math.random() * 0.7 + 0.3,
            relationship_type: "emergent",
            mutual: Math.random() > 0.5,
          });
        }
      }
    }
  }

  return {
    nodes,
    edges,
    total_relationships: edges.length,
    total_bots: nodes.length,
  };
}
