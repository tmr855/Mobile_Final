<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\OrderItem;
use App\Models\Order;
use App\Models\Product;

class OrderItemController extends Controller
{
    // GET /api/order-items
    public function index()
    {
        return OrderItem::with(['order', 'product'])->get();
    }

    // POST /api/order-items
    public function store(Request $request)
    {
        $validated = $request->validate([
            'order_id'   => 'required|exists:orders,id',
            'product_id' => 'required|exists:products,id',
            'quantity'   => 'required|integer|min:1',
            'price'      => 'required|numeric',
        ]);

        $orderItem = OrderItem::create($validated);

        return response()->json($orderItem->load(['order', 'product']), 201);
    }

    // GET /api/order-items/{id}
    public function show($id)
    {
        return OrderItem::with(['order', 'product'])->findOrFail($id);
    }

    // PUT /api/order-items/{id}
    public function update(Request $request, $id)
    {
        $validated = $request->validate([
            'order_id'   => 'sometimes|exists:orders,id',
            'product_id' => 'sometimes|exists:products,id',
            'quantity'   => 'sometimes|integer|min:1',
            'price'      => 'sometimes|numeric',
        ]);

        $item = OrderItem::findOrFail($id);
        $item->update($validated);

        return response()->json($item->load(['order', 'product']), 200);
    }

    // DELETE /api/order-items/{id}
    public function destroy($id)
    {
        $item = OrderItem::findOrFail($id);
        $item->delete();

        return response()->json(['message' => 'Order item deleted'], 204);
    }
}
