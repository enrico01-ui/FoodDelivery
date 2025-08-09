<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\OrderItem;
use App\Models\Order;

class OrderController extends Controller
{
    public function index()
    {
        $order = Order::all();
        return response()->json($order);
    }
    // 'user_id',
    //     'restaurant_id',
    //     'order_date',
    //     'total_price',
    //     'status',
    
    public function store(Request $request)
    {
        $request->validate(
            [
                'user_id' => 'required|numeric|exists:users,id',
                'restaurant_id' => 'required|numeric|exists:restaurants,id',
                'total_price' => 'required|numeric',
                'status' => 'required|string'
            ]
        );

        $order = Order::create([
            'user_id' => $request->user_id,
            'restaurant_id' => $request->restaurant_id,
            'total_price' => $request->total_price,
            'status' => $request->status
        ]);


        return response()->json([
            'message' => 'Order Created Successfully',
            'data' => $order
        ]);
    }

    public function show(Request $request)
    {
        $request->validate(
            [
                'user_id' => 'required|string|exists:users,id',
            ]
        );

        $order = Order::where('user_id', 'like', '%' . $request->user_id . '%')
                        ->get();
        
        if($order->count() > 0) {
            return response()->json([
                'message' => 'Order found',
                'data' => $order
            ], 200);
        } else {
            return response()->json([
                'message' => 'Order not found',
                'data' => []
            ], 404);
        }
    }

    public function update(Request $request)
    {
        $request->validate([
            'status' => 'required|string',
        ]);

        $order = Order::where('id', $request->id)->first();

        if($order) {
            $order->status = $request->status;
            $order->save();

            return response()->json([
                'message' => 'Order Updated Successfully',
                'data' => $order
            ], 200);
        } else {
            return response()->json([
                'message' => 'Order not found',
                'data' => []
            ], 404);
        }
    }

    public function destroy(Request $request)
    {
        $request->validate([
            'id' => 'required|string',
        ]);

        $order = Order::where('id', $request->id)->first();

        if($order) {
            $order->delete();
            return response()->json([
                'message' => 'Order deleted successfully'
            ], 200);
        } else {
            return response()->json([
                'message' => 'Order not found'
            ], 404);
        }
    }
}
