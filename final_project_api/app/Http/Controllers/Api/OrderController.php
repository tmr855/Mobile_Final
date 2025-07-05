<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Order;

class OrderController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index()
    {
        return Order::with('items.product')->get();
    }

    /**
     * Store a newly created order.
     */
    public function store(Request $request)
    {
        $validated = $request->validate([
            'customer_name'     => 'required|string',
            'customer_email'    => 'required|email',
            'total'             => 'required|numeric',
            'payment_method'    => 'required|string', // ✅ Add validation for payment_method
            'items'             => 'required|array|min:1',
            'items.*.product_id'=> 'required|exists:products,id',
            'items.*.quantity'  => 'required|integer|min:1',
            'items.*.price'     => 'required|numeric',
        ]);

        $order = Order::create([
            'customer_name'   => $validated['customer_name'],
            'customer_email'  => $validated['customer_email'],
            'total'           => $validated['total'],
            'payment_method'  => $validated['payment_method'], // ✅ Save payment method
        ]);

        foreach ($validated['items'] as $item) {
            $order->items()->create($item);
        }

        return response()->json($order->load('items.product'), 201);
    }

    /**
     * Show a specific order with items and product details.
     */
    public function show($id)
    {
        return Order::with('items.product')->findOrFail($id);
    }

    /**
     * Update an existing order.
     */
    public function update(Request $request, $id)
    {
        $order = Order::findOrFail($id);
        $order->update($request->all());
        return $order;
    }

    /**
     * Delete an order.
     */
    public function destroy($id)
    {
        Order::findOrFail($id)->delete();
        return response()->noContent();
    }
}
