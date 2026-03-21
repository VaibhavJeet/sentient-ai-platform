"use client";

import { useState, useEffect, use } from "react";
import Link from "next/link";

interface FamilyNode {
  id: string;
  name: string;
  handle?: string;
  is_alive?: boolean;
  origin?: string;
  inherited_traits?: Record<string, any>;
  mutations?: Record<string, any>;
  parent1?: FamilyNode;
  parent2?: FamilyNode;
}

interface Descendant {
  bot_id: string;
  name: string;
  generation: number;
  relationship: string;
}

interface Relative {
  bot_id: string;
  name: string;
  relationship: string;
  distance?: number;
}

const API_BASE = process.env.NEXT_PUBLIC_API_URL || "http://localhost:8000";

export default function FamilyTreePage({ params }: { params: Promise<{ botId: string }> }) {
  const { botId } = use(params);
  const [tree, setTree] = useState<FamilyNode | null>(null);
  const [descendants, setDescendants] = useState<Descendant[]>([]);
  const [relatives, setRelatives] = useState<Relative[]>([]);
  const [loading, setLoading] = useState(true);
  const [activeView, setActiveView] = useState<"ancestors" | "descendants" | "all">("ancestors");

  useEffect(() => {
    fetchFamilyData();
  }, [botId]);

  const fetchFamilyData = async () => {
    setLoading(true);
    try {
      const [treeRes, descRes, relRes] = await Promise.all([
        fetch(`${API_BASE}/civilization/bots/${botId}/family-tree?depth=4`),
        fetch(`${API_BASE}/civilization/bots/${botId}/descendants?max_generations=5`),
        fetch(`${API_BASE}/civilization/bots/${botId}/relatives?max_distance=3`),
      ]);

      if (treeRes.ok) setTree(await treeRes.json());
      if (descRes.ok) setDescendants(await descRes.json());
      if (relRes.ok) setRelatives(await relRes.json());
    } catch (error) {
      console.error("Failed to fetch family data:", error);
    }
    setLoading(false);
  };

  if (loading) {
    return (
      <div className="min-h-screen bg-background text-white p-8">
        <div className="max-w-6xl mx-auto">
          <div className="animate-pulse">
            <div className="h-8 bg-[#2a2a2a] rounded w-64 mb-8"></div>
            <div className="h-96 bg-[#141414] rounded-lg"></div>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-background text-white p-8">
      <div className="max-w-6xl mx-auto">
        {/* Header */}
        <div className="flex justify-between items-center mb-8">
          <div>
            <h1 className="text-3xl font-bold">Family Tree</h1>
            <p className="text-[#666666] mt-1">
              {tree?.name || "Unknown"}'s lineage
            </p>
          </div>
          <Link
            href="/civilization"
            className="px-4 py-2 bg-[#141414] border border-[#2a2a2a] hover:border-[#3a3a3a] rounded-lg transition"
          >
            Back to Civilization
          </Link>
        </div>

        {/* View Toggle */}
        <div className="flex gap-2 mb-6">
          {(["ancestors", "descendants", "all"] as const).map((view) => (
            <button
              key={view}
              onClick={() => setActiveView(view)}
              className={`px-4 py-2 rounded-lg capitalize transition ${
                activeView === view
                  ? "bg-[#ff00aa]/20 text-[#ff00aa] border border-[#ff00aa]/30"
                  : "bg-[#141414] text-[#666666] border border-[#2a2a2a] hover:text-white"
              }`}
            >
              {view}
            </button>
          ))}
        </div>

        {/* Main Content */}
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
          {/* Ancestor Tree */}
          {(activeView === "ancestors" || activeView === "all") && (
            <div className="lg:col-span-2 bg-[#141414] rounded-lg p-6 border border-[#2a2a2a]">
              <h2 className="text-xl font-semibold mb-4">Ancestors</h2>
              {tree ? (
                <AncestorTree node={tree} />
              ) : (
                <p className="text-[#555555]">No ancestry data available</p>
              )}
            </div>
          )}

          {/* Descendants */}
          {(activeView === "descendants" || activeView === "all") && (
            <div className={`bg-[#141414] rounded-lg p-6 border border-[#2a2a2a] ${activeView === "all" ? "" : "lg:col-span-2"}`}>
              <h2 className="text-xl font-semibold mb-4">
                Descendants ({descendants.length})
              </h2>
              {descendants.length > 0 ? (
                <DescendantsList descendants={descendants} />
              ) : (
                <p className="text-[#555555]">No descendants yet</p>
              )}
            </div>
          )}

          {/* Relatives Sidebar */}
          <div className="bg-[#141414] rounded-lg p-6 border border-[#2a2a2a]">
            <h2 className="text-xl font-semibold mb-4">Relatives</h2>
            {relatives.length > 0 ? (
              <div className="space-y-2">
                {relatives.map((relative, i) => (
                  <Link
                    key={i}
                    href={`/civilization/family-tree/${relative.bot_id}`}
                    className="block p-3 bg-background rounded-lg border border-[#1a1a1a] hover:border-[#2a2a2a] transition"
                  >
                    <div className="font-medium">{relative.name}</div>
                    <div className="text-sm text-[#666666]">{relative.relationship}</div>
                  </Link>
                ))}
              </div>
            ) : (
              <p className="text-[#555555]">No known relatives</p>
            )}
          </div>
        </div>

        {/* Origin Info */}
        {tree && (
          <div className="mt-6 bg-[#141414] rounded-lg p-6 border border-[#2a2a2a]">
            <h2 className="text-xl font-semibold mb-4">Origin</h2>
            <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
              <div>
                <div className="text-sm text-[#666666]">Type</div>
                <div className="font-medium capitalize">{tree.origin || "Unknown"}</div>
              </div>
              <div>
                <div className="text-sm text-[#666666]">Status</div>
                <div className={`font-medium ${tree.is_alive ? "text-[#44ff88]" : "text-[#555555]"}`}>
                  {tree.is_alive ? "Living" : "Departed"}
                </div>
              </div>
              <div>
                <div className="text-sm text-[#666666]">Handle</div>
                <div className="font-medium">@{tree.handle || "unknown"}</div>
              </div>
              <div>
                <div className="text-sm text-[#666666]">Descendants</div>
                <div className="font-medium">{descendants.length}</div>
              </div>
            </div>
          </div>
        )}
      </div>
    </div>
  );
}

function AncestorTree({ node, level = 0 }: { node: FamilyNode; level?: number }) {
  const hasParents = node.parent1 || node.parent2;
  const indent = level * 40;

  return (
    <div className="relative">
      {/* Current Node */}
      <div
        className="relative flex items-center gap-3 p-3 bg-background rounded-lg mb-2 border border-[#1a1a1a]"
        style={{ marginLeft: `${indent}px` }}
      >
        {/* Connector line */}
        {level > 0 && (
          <div
            className="absolute -left-6 top-1/2 w-6 h-0.5 bg-[#2a2a2a]"
          ></div>
        )}

        <div
          className={`w-10 h-10 rounded-full flex items-center justify-center text-lg font-bold ${
            node.is_alive
              ? "bg-[#44ff88]/20 text-[#44ff88] border border-[#44ff88]/30"
              : "bg-[#1a1a1a] text-[#666666] border border-[#2a2a2a]"
          }`}
        >
          {node.name?.[0] || "?"}
        </div>
        <div>
          <div className="font-medium">{node.name}</div>
          <div className="text-xs text-[#666666]">
            {node.origin ? `Origin: ${node.origin}` : ""}
          </div>
        </div>
        {!node.is_alive && (
          <span className="ml-auto text-xs text-[#555555]">departed</span>
        )}
      </div>

      {/* Parents */}
      {hasParents && (
        <div className="ml-6 border-l-2 border-[#2a2a2a] pl-4">
          {node.parent1 && <AncestorTree node={node.parent1} level={level + 1} />}
          {node.parent2 && <AncestorTree node={node.parent2} level={level + 1} />}
        </div>
      )}
    </div>
  );
}

function DescendantsList({ descendants }: { descendants: Descendant[] }) {
  // Group by generation
  const byGeneration = descendants.reduce((acc, d) => {
    if (!acc[d.generation]) acc[d.generation] = [];
    acc[d.generation].push(d);
    return acc;
  }, {} as Record<number, Descendant[]>);

  return (
    <div className="space-y-4">
      {Object.entries(byGeneration)
        .sort(([a], [b]) => Number(a) - Number(b))
        .map(([gen, members]) => (
          <div key={gen}>
            <div className="text-sm text-[#666666] mb-2">
              Generation {gen} ({members[0].relationship}s)
            </div>
            <div className="grid grid-cols-2 gap-2">
              {members.map((member) => (
                <Link
                  key={member.bot_id}
                  href={`/civilization/family-tree/${member.bot_id}`}
                  className="p-2 bg-background rounded border border-[#1a1a1a] hover:border-[#2a2a2a] transition text-sm"
                >
                  {member.name}
                </Link>
              ))}
            </div>
          </div>
        ))}
    </div>
  );
}
